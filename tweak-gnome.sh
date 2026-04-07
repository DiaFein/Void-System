#!/bin/bash

# =========================================================
# VOID LINUX + GNOME CORE TUNER (Apex Edition)
# Purpose: Ultra-Low Latency for High-Frequency Trading
# Hardware: HP 15 (Ryzen) | OS: Void Linux
# =========================================================

# 1. ROOT CHECK & TARGET ACQUISITION
# ---------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
   echo "❌ Script must be run as root: sudo $0"
   exit 1
fi

TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

echo "🚀 Applying Apex-tier optimizations for $TARGET_USER..."

# 2. THE GSETTINGS WRAPPER (Session-Aware)
# ---------------------------------------------------------
set_gsetting() {
    local schema=$1
    local key=$2
    local value=$3

    if sudo -u "$TARGET_USER" gsettings writable "$schema" "$key" >/dev/null 2>&1; then
        sudo -u "$TARGET_USER" gsettings set "$schema" "$key" "$value"
        echo "  ✔ $schema::$key → $value"
    else
        echo "  ⚠ Skipped: $schema::$key"
    fi
}

# 3. SYSTEM: REALTIME & SCHEDULING (Idempotent)
# ---------------------------------------------------------
echo "⚖️  System: Locking Realtime Permissions..."

if ! getent group realtime >/dev/null; then
    groupadd -r realtime
fi
usermod -aG realtime "$TARGET_USER"

LIMITS_FILE="/etc/security/limits.d/99-realtime.conf"
if [ ! -f "$LIMITS_FILE" ]; then
    cat > "$LIMITS_FILE" <<EOF
@realtime - rtprio 99
@realtime - memlock unlimited
@realtime - nice -20
EOF
    echo "  ✔ Realtime limits configured."
else
    echo "  ℹ️  Realtime limits already present."
fi

# 4. COMPOSITOR & SHELL (The Efficiency Core)
# ---------------------------------------------------------
echo "⚡ Tuning Mutter & Shell Performance..."

# Experimental Mutter features for frame-timing
set_gsetting org.gnome.mutter experimental-features "['kms-modifiers', 'variable-refresh-rate', 'rt-scheduler']"

# Workspace optimization: 2 is optimal for focus (Lower memory/faster context switching)
set_gsetting org.gnome.mutter dynamic-workspaces false
set_gsetting org.gnome.desktop.wm.preferences num-workspaces 2

# Disable Hot Corners (Prevent accidental compositor triggers)
set_gsetting org.gnome.shell enable-hot-corners false
set_gsetting org.gnome.desktop.interface enable-hot-corners false

# 5. UI REDRAW & ENGINE OPTIMIZATION
# ---------------------------------------------------------
echo "🎨 UI Redraw & Font Micro-Optimizations..."

set_gsetting org.gnome.desktop.interface enable-animations false
set_gsetting org.gnome.desktop.interface toolkit-accessibility false
set_gsetting org.gnome.desktop.sound event-sounds false

# Clock: Disable seconds to reduce per-second UI redraw overhead
set_gsetting org.gnome.desktop.interface clock-show-seconds false

# Font: Grayscale is computationally cheaper than RGBA/Subpixel
set_gsetting org.gnome.desktop.interface font-antialiasing 'grayscale'

# 6. NEUTER BACKGROUND NOISE (Autostart)
# ---------------------------------------------------------
echo "🧠 Silencing Background Services..."

AUTOSTART_DIR="$USER_HOME/.config/autostart"
sudo -u "$TARGET_USER" mkdir -p "$AUTOSTART_DIR"

SERVICES=(
    "tracker-miner-fs-3" 
    "tracker-extract-3" 
    "tracker-miner-apps-3"
    "org.gnome.Evolution-alarm-notify"
)

for service in "${SERVICES[@]}"; do
    sudo -u "$TARGET_USER" tee "$AUTOSTART_DIR/$service.desktop" >/dev/null <<EOF
[Desktop Entry]
Type=Application
Name=$service (Disabled)
Exec=false
Hidden=true
X-GNOME-Autostart-enabled=false
EOF
done

# Graceful terminate existing processes
pkill -u "$TARGET_USER" -f tracker 2>/dev/null || true
pkill -u "$TARGET_USER" -f evolution 2>/dev/null || true

# 7. PRIVACY & SECURITY (Double-Layered)
# ---------------------------------------------------------
echo "🛡️  Hardening Privacy & Security..."

# Location Services (Both schemas for full coverage)
set_gsetting org.gnome.desktop.privacy location-enabled false
set_gsetting org.gnome.system.location enabled false

set_gsetting org.gnome.desktop.privacy remember-recent-files false
set_gsetting org.gnome.desktop.privacy remember-app-usage false
set_gsetting org.gnome.desktop.privacy send-software-usage-stats false
set_gsetting org.gnome.desktop.privacy report-technical-problems false

set_gsetting org.gnome.desktop.privacy usb-protection true
set_gsetting org.gnome.desktop.privacy usb-protection-level 'lockscreen'

# 8. LEAN SEARCH (Activities Overview)
# ---------------------------------------------------------
set_gsetting org.gnome.desktop.search-providers disable-external true
set_gsetting org.gnome.desktop.search-providers disabled \
"['org.gnome.Photos.desktop','org.gnome.Documents.desktop','org.gnome.Contacts.desktop']"

echo ""
echo "✅ APEX TUNING COMPLETE"
echo "---------------------------------------------------------"
echo "🚀 MANDATORY REBOOT: Required to activate Realtime scheduling."
echo "👉 Post-reboot check: 'ulimit -r' should return 99."
echo "---------------------------------------------------------"
