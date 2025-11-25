# Persisted Directories and Files in `/persist`

## System-Level (modules/persist.nix)

### Directories
- `/var/log`
- `/var/lib/bluetooth`
- `/var/lib/nixos`
- `/var/lib/systemd/coredump`
- `/etc/NetworkManager/system-connections`
- `/etc/cups`
- `/var/lib/colord` (user: colord, group: colord)
- `/var/lib/flatpak`
- `/var/lib/libvirt`
- `/var/lib/nordvpn`

### Files
- `/etc/machine-id`
- `/var/keys/secret_file`

---

## User-Level Directories (`~username/`)

### Core (modules/persist.nix)
- `Desktop`
- `Downloads`
- `Templates`
- `.dotfiles`
- `.gnupg` (mode: 0700)
- `.ssh` (mode: 0700)
- `.nixops` (mode: 0700)
- `.local/share/keyrings` (mode: 0700)
- `.local/share/direnv`
- `.local/share/themes`
- `.local/share/icons`
- `.local/share/applications`
- `.config/gh`
- `.config/nordvpn`
- `.config/sh.cider.genten`
- `.config/remmina`
- `.zsh`
- `.config/dconf`
- `.config/variety`

### AI (modules/ai.nix)
- `.gemini`
- `.claude`

### Browsers (modules/browsers.nix)
- `.config/google-chrome`
- `.config/BraveSoftware`

### Communication (modules/communication.nix)
- `.local/share/TelegramDesktop`
- `.config/discord`
- `.config/Mattermost`
- `.config/Mailspring`
- `.config/Caprine`

### Development (modules/development.nix)
- `.config/Code`
- `.config/MongoDB Compass`
- `.vscode`

### Flatpak (modules/flatpak.nix)
- `.local/share/flatpak`
- `.var/app/app.zen_browser.zen`
- `.var/app/us.zoom.Zoom`

### Games (modules/games.nix)
- `.scidvspc`
- `.local/share/gnome-2048`

### Media (modules/media.nix)
- `.local/share/lollypop`
- `.cache/lollypop`
- `.config/obs-studio`

### Office (modules/office.nix)
- `.config/anytype`

### COSMIC Desktop (desktops/cosmic.nix)
- `.local/state/cosmic-comp`
- `.local/state/cosmic`
- `.config/cosmic`

### Cinnamon Desktop (desktops/cinnamon.nix)
- `.config/cinnamon`
- `.config/cinnamon-session`
- `.local/share/cinnamon`

### XFCE/Qtile Desktop (desktops/xfce.nix)
- `.local/share/qtile`
- `.cache/qtile`
- `.cache/rofi`
- `.config/xfce4/xfconf`

---

## User-Level Files (`~username/`)

### Core (modules/persist.nix)
- `.screenrc`
- `.gitconfig`
- `.zprofile`
- `.zlogin`
- `.histfile`
- `.zsh_history`
- `.cache/wallust/sequences`

### GNOME Desktop (desktops/gnome.nix)
- `.config/gnome-initial-setup-done`

### COSMIC Desktop (desktops/cosmic.nix)
- `.config/cosmic-initial-setup-done`
