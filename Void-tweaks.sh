#!/bin/bash

# ==============================================================================
# VOID LINUX HIGH-PERFORMANCE TRADING DESK DEPLOYMENT (STATE-AWARE)
# Target: AMD GPU, Wayland, Multi-4K 120Hz, Web-Based Trading
# Execution: Run as ROOT
# ==============================================================================

# --- 0. Safety & Environment Guard ---
[ "$EUID" -eq 0 ] || { echo "[!] CRITICAL: This script must be run as root."; exit 1; }
[ -d /sys ] || { echo "[!] CRITICAL: /sys not detected. Environment is broken. Exiting."; exit 1; }
set -e

echo "======================================================================"
echo "      INITIALIZING STATE-AWARE VOID TRADING DEPLOYMENT                "
echo "======================================================================"

# --- 1. Preflight: System Update & Dependency Check ---
echo "[+] Syncing repositories and updating base system..."
xbps-install -Sy void-repo-nonfree || true
xbps-install -Syu -y

REQUIRED_PKGS="linux-firmware-amd mesa-dri mesa-vaapi mesa-vulkan-radeon \
    gnome-core gdm dbus elogind NetworkManager \
    ethtool pciutils zramen irqbalance lm_sensors cpupower dconf"

echo "[+] Verifying required hardware and UI packages..."
xbps-install -y $REQUIRED_PKGS

# --- 2. Purging GNOME Indexing Miners ---
echo "[+] Checking for background indexing bloat (tracker3)..."
if xbps-query -Rs tracker3-miners >/dev/null 2>&1; then
    xbps-remove -Fy tracker3-miners || true
fi

# --- 3. Non-Destructive GRUB Hardening ---
echo "[+] Analyzing current GRUB configuration..."
[ -f /etc/default/grub ] || printf 'GRUB_CMDLINE_LINUX_DEFAULT=""\n' > /etc/default/grub

add_grub_flag() {
    local flag="$1"
    local grub_file="/etc/default/grub"
    
    # Check if the flag is already present anywhere in the GRUB_CMDLINE_LINUX_DEFAULT line
    if grep -E "^GRUB_CMDLINE_LINUX_DEFAULT=" "$grub_file" | grep -q -E "[[:space:]\"']${flag}([[:space:]\"']|$)"; then
        echo "  -> [SKIPPED] Flag '${flag}' already exists in GRUB."
    else
        echo "  -> [ADDED] Injecting '${flag}' into GRUB_CMDLINE_LINUX_DEFAULT."
        # Safely inject the flag right before the closing double-quote
        sed -i -E "s/^(GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*)\"/\1 ${flag}\"/" "$grub_file"
        GRUB_CHANGED=1
    fi
}

GRUB_CHANGED=0
add_grub_flag "amd_pstate=active"
add_grub_flag "audit=0"
add_grub_flag "nowatchdog"
add_grub_flag "nmi_watchdog=0"

if [ "$GRUB_CHANGED" -eq 1 ]; then
    echo "  -> Updating GRUB bootloader..."
    # Clean up any accidental double spaces created during insertion
    sed -i -E 's/  +/ /g' /etc/default/grub
    [ -d /boot/grub ] && grub-mkconfig -o /boot/grub/grub.cfg
fi

# --- 4. State-Aware Sysctl Tuning ---
echo "[+] Analyzing live kernel sysctl parameters..."
mkdir -p /etc/sysctl.d
SYSCTL_CONF="/etc/sysctl.d/99-trading-ultra.conf"
> "$SYSCTL_CONF" # Clear our drop-in file for a fresh idempotency run

apply_sysctl() {
    local key="$1"
    local desired="$2"
    local current
    
    # Read the current live value from the kernel
    current=$(sysctl -n "$key" 2>/dev/null || echo "MISSING")
    
    if [ "$current" != "$desired" ]; then
        echo "  -> [UPDATED] $key : $current -> $desired"
        echo "$key=$desired" >> "$SYSCTL_CONF"
    else
        echo "  -> [PRESERVED] $key is already optimal ($current)."
    fi
}

apply_sysctl "kernel.dmesg_restrict" "1"
apply_sysctl "kernel.timer_migration" "0"
apply_sysctl "kernel.sched_wakeup_granularity_ns" "1500000"
apply_sysctl "kernel.sched_autogroup_enabled" "0"
apply_sysctl "kernel.sched_child_runs_first" "0"
apply_sysctl "vm.stat_interval" "10"
apply_sysctl "vm.swappiness" "10"
apply_sysctl "vm.dirty_ratio" "10"
apply_sysctl "vm.dirty_background_ratio" "5"
apply_sysctl "vm.page-cluster" "0"
apply_sysctl "net.core.default_qdisc" "fq"
apply_sysctl "net.ipv4.tcp_congestion_control" "bbr"
apply_sysctl "net.ipv4.tcp_low_latency" "1"
apply_sysctl "net.ipv4.tcp_fastopen" "3"
apply_sysctl "net.ipv4.tcp_no_metrics_save" "1"
apply_sysctl "net.ipv4.tcp_retries2" "8"
apply_sysctl "net.core.busy_read" "50"
apply_sysctl "net.core.busy_poll" "50"
apply_sysctl "net.core.netdev_max_backlog" "250000"

# Apply only if our file isn't empty
if [ -s "$SYSCTL_CONF" ]; then
    sysctl --system >/dev/null 2>&1 || true
fi

# Reduce IRQ Jitter dynamically
echo 2 > /proc/irq/default_smp_affinity 2>/dev/null || true

# --- 5. Enabling TCP BBR Congestion Control ---
echo "[+] Checking TCP BBR kernel module..."
mkdir -p /etc/modules-load.d
if ! grep -q "tcp_bbr" /etc/modules-load.d/bbr.conf 2>/dev/null; then
    echo "tcp_bbr" >> /etc/modules-load.d/bbr.conf
fi

# --- 6. Raising WebSocket Limits (File Descriptors) ---
echo "[+] Checking File Descriptor limits..."
mkdir -p /etc/security/limits.d
LIMITS_FILE="/etc/security/limits.d/99-trading-limits.conf"

if [ ! -f "$LIMITS_FILE" ]; then
    cat <<'EOF' > "$LIMITS_FILE"
* soft nofile 500000
* hard nofile 1048576
root soft nofile 500000
root hard nofile 1048576
EOF
    echo "  -> WebSocket limits deployed."
else
    echo "  -> [PRESERVED] Custom limits file already exists."
fi

if ! grep -q "session required pam_limits.so" /etc/pam.d/system-auth; then
    echo "session required pam_limits.so" >> /etc/pam.d/system-auth
fi

# --- 7. Hardware Acceleration for Web Browsers ---
echo "[+] Checking Chromium/Brave Wayland & Vulkan flags..."
mkdir -p /etc/chromium
CHROMIUM_FLAGS="/etc/chromium/custom-flags.conf"
touch "$CHROMIUM_FLAGS"

add_browser_flag() {
    local flag="$1"
    if ! grep -q "^${flag}" "$CHROMIUM_FLAGS"; then
        echo "$flag" >> "$CHROMIUM_FLAGS"
    fi
}

add_browser_flag "--ignore-gpu-blocklist"
add_browser_flag "--enable-gpu-rasterization"
add_browser_flag "--enable-zero-copy"
add_browser_flag "--use-vulkan"
add_browser_flag "--enable-features=Vulkan"
add_browser_flag "--js-flags=\"--max-opt=3\""
add_browser_flag "--ozone-platform-hint=auto"
add_browser_flag "--enable-wayland-ime"

echo 'export CHROMIUM_USER_FLAGS="$(cat /etc/chromium/custom-flags.conf | tr '\''\n'\'' '\'' '\'')" ' > /etc/profile.d/browser-perf.sh
chmod +x /etc/profile.d/browser-perf.sh

# --- 8. Global GNOME Performance (dconf) ---
echo "[+] Verifying GNOME desktop performance overrides..."
mkdir -p /etc/dconf/profile
if [ ! -f /etc/dconf/profile/user ]; then
    cat <<'EOF' > /etc/dconf/profile/user
user-db:user
system-db:local
EOF
fi

mkdir -p /etc/dconf/db/local.d
DCONF_TRADING="/etc/dconf/db/local.d/00-trading-performance"
if [ ! -f "$DCONF_TRADING" ]; then
    cat <<'EOF' > "$DCONF_TRADING"
[org/gnome/desktop/interface]
enable-animations=false

[org/gnome/software]
download-updates=false

[org/freedesktop/tracker3/miner/files]
enable-monitors=false
EOF
    dconf update
fi

# --- 9. Boot Optimizations (/etc/rc.local) ---
echo "[+] Staging bare-metal hardware initialization script..."
cat <<'EOF' > /usr/local/bin/trading-boot-init.sh
#!/bin/bash
# 1. Disable Transparent Huge Pages (Reduces memory latency spikes)
echo never > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null

# 2. Set CPU Governor to Maximum Readiness
command -v cpupower >/dev/null && cpupower frequency-set -g performance >/dev/null 2>&1

# 3. Lock AMD GPU to Performance State
if [ -f /sys/class/drm/card0/device/power_dpm_force_performance_level ]; then
  echo high > /sys/class/drm/card0/device/power_dpm_force_performance_level
elif [ -f /sys/class/drm/card0/device/power_dpm_state ]; then
  echo performance > /sys/class/drm/card0/device/power_dpm_state
fi

# 4. Optimize Block Device Affinity (Storage routing)
for dev in /sys/block/nvme* /sys/block/sd*; do
    [ -e "$dev" ] || continue
    [ -e "$dev/queue/rq_affinity" ] && echo 2 > "$dev/queue/rq_affinity" 2>/dev/null
done
EOF
chmod +x /usr/local/bin/trading-boot-init.sh

# Ensure rc.local executes our boot script natively via Void's runit
if [ ! -f /etc/rc.local ]; then
    echo '#!/bin/sh' > /etc/rc.local
fi
if ! grep -q "trading-boot-init.sh" /etc/rc.local; then
    echo "/usr/local/bin/trading-boot-init.sh" >> /etc/rc.local
fi
chmod +x /etc/rc.local

# --- 10. Enabling Core Services ---
echo "[+] Enabling core system services..."
for s in dbus elogind NetworkManager zramen irqbalance; do
    [ -d "/etc/sv/$s" ] && ln -sfn "/etc/sv/$s" /var/service/
done

# Start GDM last to avoid breaking the script execution environment
[ -d "/etc/sv/gdm" ] && ln -sfn "/etc/sv/gdm" /var/service/

echo "======================================================================"
echo "[SUCCESS] State-Aware Update Complete. Reboot to apply changes."
echo "======================================================================"
