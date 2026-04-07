# Void Linux + GNOME = ❤️

### Quick Links

- [Installation](#installation)
- [Network configuration - Part 1 (wpa_supplicant)](#net_conf_part1)
- [Update the System](#update_system)
- [Add non-free repository](#nonfree_repo)
- [Install recommended packages](#recommended_packs)
- [Install development packages](#dev_packs)
- [Desktop environment (GNOME)](#gnome)
- [Enable required services](#required_services)
- [Network configuration - Part 2 (Network Manager)](#net_conf_part2)
- [Audio configuration (PulseAudio)](#audio_conf)
- [Bluetooth configuration (BlueZ)](#bluetooth_conf)
- [Printing support configuration](#printing_conf)
- [Cron configuration (cronie)](#cron_conf)
- [Notebook Power Saving configuration](#powersaving_conf)
- [Fonts installation](#fonts_conf)
- [Office suite (LibreOffice)](#office_suite)
- [Internet browser installation (Firefox)](#browser)
- [Media player (VLC)](#media_player)
- [Backup software (Timeshift)](#backup_soft)
- [Logging Daemon activation](#logging_daemon)
- [Profile Sync Daemon (PSD)](#psd)
- [Bash aliases](#aliases)

### Optional

- [Tilix (tiling terminal)](#tilix)
- [Fzf (fuzzy finder)](#fzf)
- [Zoxide (smarter cd command)](#zoxide)
- [Bat (cat clone with wings)](#bat)
- [Ripgrep (grep alternative)](#ripgrep)
- [Exa (modern replacement for ‘ls’)](#exa)
- [Dust (intuitive version of du)](#dust)
- [Lazygit (git tui)](#lazygit)
- [Neovim + AstroNvim](#nvim)
- [OctoXBPS (xbps frontend)](#octoxbps)
- [VSV (Void Service Manager)](#vsv)
- [Docker](#docker)
- [Flatpak](#flatpak)
- [Nix package manager](#nix_pkg)
- [Alternative Browser (Brave)](#browser_alt)
- [Dconf Editor](#dconf)
- [Nautilus embedded terminal](#nautilus_terminal)
- [Syncthing (peer-to-peer file synchronization)](#syncthing)
- [Sushi (Quick Look)](#sushi)
- [Intel's Microcode](#intel_microcode)
- [Fonts, Theme, Icons, Cursor, Extensions, Wallpaper](#theming)

## Installation <a id='installation'></a>

Void Linux installation was done following the [official guide](https://docs.voidlinux.org/installation/live-images/guide.html).

![Void_GNOME](https://user-images.githubusercontent.com/31778860/193263474-e9ddcc53-fe35-482a-aa0d-6eaff1dc7174.jpg)

## Network configuration - Part 1 (wpa_supplicant) <a id='net_conf_part1'></a>

1. Check the name of our interface:
    ```bash
    ip a
    ```
    In my case, **“wlp3s0”** is the name of the Wi-Fi interface.

2. Create a configuration file to connect to Wi-Fi:
    ```bash
    sudo vi /etc/wpa_supplicant/wpa_supplicant-wlp3s0.conf
    ```
    Write these lines into the file and then save it:
    ```bash
    ctrl_interface=DIR=/run/wpa_supplicant
    update_config=1
    ```
3. Add the information about your wireless network to the file:
    ```bash
    wpa_passphrase SSID PASSWORD >> /etc/wpa_supplicant/wpa_supplicant-wlp3s0.conf
    ```
4. Enable dhcpd and wpa_supplicant
   ```bash
    sudo ln -s /etc/sv/dhcpcd /var/service

    sudo ln -s /etc/sv/wpa_supplicant /var/service

    sudo sv up dhcpcd

    sudo sv up wpa_supplicant
   ```
5. Run this last command:
    ```bash
    wpa_supplicant -B -i wlp1s0 -c /etc/wpa_supplicant/wpa_supplicant-wlp3s0.conf
    ```
6. To check your connection run:
   ```bash
    ping google.com
   ```
## Update the System <a id='update_system'></a>
- 
    ```bash
    sudo xbps-install -Suv
    ```

## Add non-free repository <a id='nonfree_repo'></a>
- 
    ```bash
    sudo xbps-install -Rs void-repo-nonfree 
    ```   

## Install recommended packages <a id='recommended_packs'></a>
- 
    ```bash
    sudo xbps-install curl wget git xz unzip zip nano vim gptfdisk xtools mtools mlocate ntfs-3g fuse-exfat bash-completion linux-headers gtksourceview4 ffmpeg mesa-vdpau mesa-vaapi htop
    ```  

## Install development packages <a id='dev_packs'></a>
- 
    ```bash
    sudo xbps-install autoconf automake bison m4 make libtool flex meson ninja optipng sassc
    ``` 


## Desktop environment (GNOME) <a id='gnome'></a>

1. Install the X Window System:
    ```bash
    sudo xbps-install xorg
    ```
2. Install desktop environment:
    ```bash
    sudo xbps-install gnome
    ```
3. Install display manager
    ```bash
    sudo xbps-install gdm
    ```
    Enable **gdm** service:
    ```bash
    sudo ln -s /etc/sv/gdm /var/service
    ```
4. Install xdg utilites:
    ```bash
    sudo xbps-install -Rs xdg-desktop-portal xdg-desktop-portal-gtk xdg-user-dirs xdg-user-dirs-gtk xdg-utils
    ```
5. Install gnome-browser-connector (prevously known as chrome-gnome-shell):
    ```bash
    sudo xbps-install gnome-browser-connector
    ```
## Enable required services <a id='required_services'></a>

1. Install dbus:
    ```bash
    sudo xbps-install -y dbus
    ``` 
    Enable dbus service:
    ```bash
    sudo ln -s /etc/sv/dbus /var/service
    ```
2. Install elogind:
    ```bash
    sudo xbps-install -y elogind
    ``` 
    Enable elogind service:
    ```bash
    sudo ln -s /etc/sv/elogind /var/service
    ```
    
## Network configuration - Part 2 (Network Manager) <a id='net_conf_part2'></a>

1. Install Network Manager:
    ```bash
    sudo xbps-install NetworkManager NetworkManager-openvpn NetworkManager-openconnect NetworkManager-vpnc NetworkManager-l2tp
    ``` 

2. Enable Network Manager service:
    ```bash
    sudo ln -sv /etc/sv/NetworkManager /var/service
    ``` 
    Before enabling the NetworkManager daemon, **disable** any other network management services, such as **dhcpcd**, **wpa_supplicant**.

##  Audio configuration <a id='audio_conf'></a>
- Install PulseAudio:
    ```bash
    sudo xbps-install pulseaudio pulseaudio-utils pulsemixer alsa-plugins-pulseaudio
    ```
    Had some issues with **pipewire**, maybe will give a try in the future...

## Bluetooth configuration <a id='bluetooth_conf'></a>

1. Install BlueZ:
    ```bash
    sudo xbps-install bluez
    ```

2. Enable Bluetooth service:
    ```bash
    sudo ln -sv /etc/sv/bluetoothd /var/service
    ```
3. Add user to the group:
    ```bash
    sudo useradd -G bluetooth ${USER}
    ```

## Printing support configuration <a id='printing_conf'></a>

1. Install CUPS:
    ```bash
    sudo xbps-install cups cups-pk-helper cups-filters foomatic-db foomatic-db-engine
    ```
2. Enable CUPS service:
    ```bash
    sudo ln -sv /etc/sv/cupsd /var/service
    ```
3. Optional:
    - Epson Printer:
        ```bash
        sudo xbps-install -Rs epson-inkjet-printer-escpr imagescan iscan-data
        ```
    - HP Printer:
        ```bash
        sudo xbps-install -Rs hplip-gui
        ```
    - Canon Printer:
        ```bash
        sudo xbps-install -Rs cnijfilter2
        ```
    - Brother Printer:
        ```bash
        sudo xbps-install -Rs brother-brlaser
        ```
        ```bash
        # SANE scanner driver for brscan3-compatible Brother scanners
        sudo xbps-install brother-brscan3

        # SANE scanner driver for brscan4-compatible printers	
        sudo xbps-install brother-brscan4	

        # CUPS wrapper driver for the brother DCP-197C printer/scanner
        sudo xbps-install brother-dcp197c-cupswrapper	

        # LPR driver for the brother DCP-197C printer/scanner 
        sudo xbps-install brother-dcp197c-lpr	
        ```

## Cron configuration <a id='cron_conf'></a>

1. Install cronie:
    ```bash
    sudo xbps-install -y cronie
    ```
2. Enable cronie service:
    ```bash
    sudo ln -sv /etc/sv/cronie /var/service
    ```

## Notebook Power Saving configuration <a id='powersaving_conf'></a>

1. Install TLP and PowerTop:
    ```bash
    sudo xbps-install tlp tlp-rdw powertop
    ```
2. Enable TLP service:
    ```bash
    sudo ln -sv /etc/sv/tlp /var/service
    ```

## Fonts installation <a id='fonts_conf'></a>

1. Install Noto fonts:
    ```bash
    sudo xbps-install -Rs noto-fonts-emoji noto-fonts-ttf noto-fonts-ttf-extra
    ```
2. Install microsoft fonts:
    ```bash
    git clone https://github.com/void-linux/void-packages
    cd void-packages
    ./xbps-src binary-bootstrap
    echo "XBPS_ALLOW_RESTRICTED=yes" >> etc/conf
    ```
    Installation:
    ```bash
    ./xbps-src pkg -f msttcorefonts
    xi msttcorefonts
    ```

## Office suite <a id='office_suite'></a>

- Install LibreOffice:
    ```bash
    sudo xbps-install libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-draw libreoffice-math libreoffice-base libreoffice-gnome libreoffice-i18n-en-US
    ```

## Internet browser installation <a id='browser'></a>

1. Install Firefox:
    ```bash
    sudo xbps-install firefox firefox-i18n-en-US
    ```
2. Set better font for firefox:
    ```bash
    sudo ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
    sudo xbps-reconfigure -f fontconfig
    ``` 

## Media player <a id='media_player'></a>

- Install VLC Media Player:
    ```bash
    sudo xbps-install vlc
    ```

## Backup software <a id='backup_soft'></a>

- Install Timeshift:
    ```bash
    sudo xbps-install timeshift
    ```
 
## Logging Daemon activation <a id='logging_daemon'></a>

- By default, Void comes with no logging daemon:
    ```bash
    sudo xbps-install -Rs socklog-void
    sudo ln -s /etc/sv/socklog-unix /var/service/
    sudo ln -s /etc/sv/nanoklogd /var/service/
    ```

## Profile Sync Daemon (PSD) <a id='psd'></a>

- PSD is a service that symlinks & syncs browser profile directories to RAM, thus reducing HDD/SSD calls & speeding up browsers. You can get it from here. This helps Firefox & Chromium reduce ram usage.
    ```bash
    git clone https://github.com/madand/runit-services
    cd runit-services
    sudo mv psd /etc/sv/
    sudo ln -s /etc/sv/psd /var/service/
    sudo chmod +x etc/sv/psd/*
    ```

## Bash aliases <a id='aliases'></a>

1. Create bash aliases:
    ```bash
    sudo nano ~/.bash_aliases
    ``` 
2. Add this script:
    ```bash
    alias xu='sudo xbps-install xbps && sudo xbps-install -Suv'
    alias xin='sudo xbps-install'
    alias xr='sudo xbps-remove -Rcon'
    alias xl='xbps-query -l'
    alias xf='xl | grep'
    alias xs='xbps-query -Rs'
    alias xd='xbps-query -x'
    alias clrk='sudo vkpurge rm all && sudo rm -rf /var/cache/xbps/*'
    alias halt='sudo halt'
    alias poweroff='sudo poweroff'
    alias reboot='sudo reboot'
    alias shutdown='sudo shutdown'
    ``` 
3. Open bash config file:
    ```bash
    sudo nano ~/.bashrc
    ```
4. Add this line:
    ```bash
    if [ -f ~/.bash_aliases ]; then 
        . ~/.bash_aliases;
    fi
    ```
4. In the end:
    ```bash
    source ~/.bashrc
    ```

# Optional

<!-- sudo groupadd usbmon -->

![Void_Tilix](https://user-images.githubusercontent.com/31778860/193263930-17229278-0c9f-4f60-ae83-cacda34c5d77.jpg)

## Tilix <a id='tilix'></a>

1. Tiling terminal emulator
    ```bash
    sudo xbps-install tilix
    ```
2. To use in quake mode (wayland not supported), create custom shortcut and add this command:
    ```bash
    tilix --quake
    ```

## Fzf <a id='fzf'></a>

- A command-line fuzzy finder
    ```bash
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
    ```

## Zoxide <a id='zoxide'></a>

1. zoxide is a smarter cd command, inspired by z and autojump:
    ```bash
    sudo xbps-install -S zoxide
    ```
2. Add this to your configuration (usually ~/.bashrc):
    ```bash
    eval "$(zoxide init bash)"
    ```

## Bat <a id='bat'></a>

1. A cat(1) clone with wings:
    ```bash
    sudo xbps-install -Su bat
    ```
2. Add alias to the previously create **bash_aliases** file:
    ```bash
    alias cat='bat'
    ```

## Ripgrep <a id='ripgrep'></a>

1. Grep alternative:
    ```bash
    sudo xbps-install -Su ripgrep
    ```
2. Add alias to the previously create **bash_aliases** file:
    ```bash
    alias grep='rg'
    ```

## Exa <a id='exa'></a>

1. A modern replacement for ‘ls’:
    ```bash
    sudo xbps-install -Su exa
    ```
2. Add alias to the previously create **bash_aliases** file:
    ```bash
    alias ls='exa --icons'
    ```

## Dust <a id='dust'></a>

1. A more intuitive version of du in rust:
    ```bash
    sudo xbps-install -Su dust
    ```
2. Add alias to the previously create **bash_aliases** file:
    ```bash
    alias du='dust'
    ```    

## Lazygit <a id='lazygit'></a>

- Simple terminal UI for git commands:
    ```bash
    sudo xbps-install -Su lazygit
    ```

## Neovim + AstroNvim <a id='nvim'></a>

1. Install Neovim:
    ```bash
    sudo xbps-install -Su neovim
    ```
1. Install AstroNvim:
    ```bash
    git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim
    nvim +PackerSync
    ```
    
## OctoXBPS <a id='octoxbps'></a>

- XBPS front end
    ```bash
    sudo xbps-install -S octoxbps
    ```

## VSV <a id='vsv'></a>
- Manage and view runit services:
    ```bash
    sudo xbps-install vsv 
    ```

## Docker <a id='docker'></a>

1. Install docker:
    ```bash
    sudo xbps-install -Su docker
    ```
2. Enable required services:
    ```bash
    sudo ln -s /etc/sv/containerd /var/service
    sudo ln -s /etc/sv/docker /var/service
    ```
3. Add user to group:
    ```bash
    sudo groupadd docker
    sudo usermod -aG docker ${USER}
    ```
4. Set respective permissions:
    ```bash
    sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
    sudo chmod g+rwx "$HOME/.docker" -R
    ```

## Flatpak <a id='flatpak'></a>

1. Install Flatpak:
    ```bash
    sudo xbps-install -S flatpak
    ```
2. Add the Flathub repository:
    ```bash
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    ```
3. Restart.

## Nix package manager <a id='nix_pkg'></a>

1. Install Nix:
    ```bash
    sudo xbps-install -Sy nix
    ```
2. Activate Nix Daemon:
    ```bash
    sudo ln -s /etc/sv/nix-daemon /var/service/
    source /etc/profile
    ```
3. Add channels:
    ```bash
    # Unstable 
    nix-channel --add https://nixos.org/channels/nixpkgs-unstable unstable
    # NixOS 22.05
    nix-channel --add https://nixos.org/channels/nixos-22.05 nixpkgs
    # Update channels 
    nix-channel --update
    # List channels
    nix-channel --list 
    ```
4. To see installed applications in the launcher create a symlink to Nix applications directory:
    ```bash
    sudo ln -s "$HOME/.nix-profile/share/applications" "$HOME/.local/share/applications/nix-env"
    ``` 

## Alternative Browser (Brave) <a id='browser_alt'></a>

- Install Brave browser using nix:
    ```bash
    nix-env -iA nixpkgs.brave
    ```

## Dconf Editor <a id='dconf'></a>
- Applications internal settings viewer and editor:
    ```bash
    sudo xbps-install dconf-editor
    ```    

## Nautilus embedded terminal <a id='nautilus_terminal'></a>

1. Install dependencies:
    ```bash
    sudo xbps-install python3 python3-pip python3-psutil
    ```
2. Install Nautilus Terminal:
    ```bash
    sudo xbps-install nautilus-python
    ```
3. Check that the extension is properly installed:
    ```bash
    nautilus-terminal --check
    python3 -m nautilus_terminal --check
    ```
4. If everything is OK, the output should be:
    ```
    Nautilus Python: Installed
    Nautilus Terminal Extension: Installed
    ```
5. To edit extension configs run:
    ```bash
    dconf-editor /org/flozz/nautilus-terminal
    ```

## Syncthing <a id='syncthing'></a>

1. Install Syncthing:
    ```bash
    sudo xbps-install -Rs syncthing 
    ```
2. Starting Syncthing automatically when system starts:
    ```bash
    sudo cp /usr/share/applications/syncthing-start.desktop ~/.config/autostart/
    ```
    
## Gnome Sushi <a id='sushi'></a>

1. File previewer for the GNOME desktop (macOS Quick Look):
    ```bash
    sudo xbps-install -Rs sushi 
    ```

## Intel's Microcode <a id='intel_microcode'></a>

1. Install Intel's Microcode:
    ```bash
    sudo xbps-install -Rs intel-ucode 
    ```
2. Reconfigure your kernel, according your kernel name:
    ```bash
    sudo xbps-reconfigure -f linux<kernel_version>
    ```
    To find your Linux kernel version, you can use
    ```bash   
    sudo xbps-query -l | grep linux
    ```

# Fonts, Theme, Icons, Cursor, Extensions, Wallpaper <a id='theming'></a>

![Void_Nautilus](https://user-images.githubusercontent.com/31778860/193264045-85237651-9b58-41c2-9af0-5b5d8dd60974.jpg)

**System Fonts:**

* Interface Text: [Inter Regular](https://github.com/rsms/inter)
* Document Text: [Inter Regular](https://github.com/rsms/inter)
* Monospace Text: [JetBrains Mono Regular](https://github.com/JetBrains/JetBrainsMono)
* Legacy Window Titles: [Inter Medium](https://github.com/rsms/inter)

**Terminal Font:** [ShureTechMono Nerd Font Mono Regular](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/ShareTechMono)

**Prompt Theme Engine:** [Oh My Posh](https://ohmyposh.dev/)

**Theme:** [Fluent GTK Theme](https://github.com/vinceliuice/Fluent-gtk-theme) (use `--icon void` flag to replace Activities with Void icon)

**Icons:** [Fluent Icon Theme](https://github.com/vinceliuice/Fluent-icon-theme) (color Grey)

**Cursor:** [Borealis Cursors](https://github.com/alvatip/Borealis-cursors)

**Wallpaper:** [VOID LINUX](https://wallpapercave.com/w/wp9031475)

**Extensions:**

* [AppIndicator and KStatusNotifierItem Support](https://extensions.gnome.org/extension/615/appindicator-support/)
* [Bluetooth Quick Connect](https://extensions.gnome.org/extension/1401/bluetooth-quick-connect/)
* [Clipboard History](https://extensions.gnome.org/extension/4839/clipboard-history/) or [Pano - Clipboard Manager](https://extensions.gnome.org/extension/5278/pano/) (Dependencies: `sudo xbps-install libgda gsound`)
* [Color Picker](https://extensions.gnome.org/extension/3396/color-picker/)
* [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)
* [Disconnect Wifi](https://extensions.gnome.org/extension/904/disconnect-wifi/)
* [Easy Docker Containers](https://extensions.gnome.org/extension/2224/easy-docker-containers/)
* [Espresso](https://extensions.gnome.org/extension/4135/espresso/)
* [Frippery Move Clock](https://extensions.gnome.org/extension/2/move-clock/)
* [Mute/Unmute](https://extensions.gnome.org/extension/5088/muteunmute/)
* [No Overview at Startup](https://extensions.gnome.org/extension/4099/no-overview/)
* [Notification Banner Position](https://extensions.gnome.org/extension/4105/notification-banner-position/)
* [Printers](https://extensions.gnome.org/extension/1218/printers/)
* [Resource Monitor](https://extensions.gnome.org/extension/1634/resource-monitor/)
* [Sound Output Device Chooser](https://extensions.gnome.org/extension/906/sound-output-device-chooser/)
* [Status Area Horizontal Spacing](https://extensions.gnome.org/extension/355/status-area-horizontal-spacing/)
* [Syncthing Icon](https://extensions.gnome.org/extension/989/syncthing-icon/)
* [Tiling Assistant](https://extensions.gnome.org/extension/3733/tiling-assistant/)
* [Toggle Night Light](https://extensions.gnome.org/extension/3933/toggle-night-light/)
* [Top Panel Workspace Scroll](https://extensions.gnome.org/extension/701/top-panel-workspace-scroll/)
* [Transparent Window Moving](https://extensions.gnome.org/extension/1446/transparent-window-moving/)
* [Tweaks & Extensions in System Menu](https://extensions.gnome.org/extension/1653/tweaks-in-system-menu/)
* [User Themes](https://extensions.gnome.org/extension/19/user-themes/)
* [Window Is Ready - Notification Remover](https://extensions.gnome.org/extension/1007/window-is-ready-notification-remover/)