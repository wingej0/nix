# Plasma Persistence Setup Instructions

## Initial Rebuild with Plasma Enabled

```bash
sudo nixos-rebuild switch --flake .#darter-pro
```

## Setup Configuration Persistence

1. Log out and log back in through SDDM (you should see the SDDM login screen)
2. Log into Plasma session

3. Make your desired configuration changes:
   - Move the dock/panel
   - Change the theme
   - Change the wallpaper
   - Adjust any other settings you want to persist

4. Copy the configuration files to persist storage:
   ```bash
   sudo cp ~/.config/kded5rc ~/.config/kdeglobals ~/.config/kglobalshortcutsrc ~/.config/kwinrc ~/.config/plasma-localerc ~/.config/plasma-org.kde.plasma.desktop-appletsrc ~/.config/plasmanotifyrc ~/.config/plasmashellrc /persist/home/wingej0/.config/
   ```

5. Verify the files were copied:
   ```bash
   ls -la /persist/home/wingej0/.config/ | grep -E "(plasma|kde|kwin)"
   ```

6. Reboot to verify all settings persist:
   ```bash
   sudo reboot
   ```

## How Persistence Works

The impermanence module creates symlinks from `~/.config/` to `/persist/home/wingej0/.config/`, but only for files that already exist in `/persist`. This is why we need to manually copy the files after configuring Plasma for the first time.

After the initial setup, all changes to these config files will automatically persist across reboots.
