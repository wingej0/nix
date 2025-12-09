# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS configuration repository using flakes, home-manager, and impermanence. The configuration supports multiple hosts with different desktop environments and is built around a btrfs-based impermanent root filesystem that rolls back on every boot.

## Building and Deploying

### Rebuild System
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

Available hostnames:
- `darter-pro` - System76 laptop with Qtile desktop
- `nix-vm` - Virtual machine with GNOME desktop

### Test Configuration Without Switching
```bash
sudo nixos-rebuild test --flake .#<hostname>
```

### Update Flake Inputs
```bash
nix flake update
```

### Update Specific Input
```bash
nix flake lock --update-input <input-name>
```

## Architecture

### Flake-Based Configuration

The system uses `flake.nix` as the entry point, which defines:
- Input dependencies (nixpkgs, home-manager, impermanence, qtile, NUR, etc.)
- NixOS configurations per host with `specialArgs` for username and hostname
- All hosts use `./hosts` as their base module

### Host Configuration Structure

Configurations are organized in `hosts/default.nix` which:
- Defines `commonModules` - shared across all hosts (users, impermanence, packages, fonts, etc.)
- Defines `desktops` - available desktop environments (gnome, plasma, cosmic, xfce, cinnamon, qtile)
- Defines `hostConfigs` - per-host module lists including desktop choice and optional modules

Each host has:
- `hosts/<hostname>/configuration.nix` - host-specific settings (boot, networking, hardware)
- `hosts/<hostname>/hardware-configuration.nix` - hardware scan results with btrfs subvolume mounts

### Impermanence System

The system uses a sophisticated impermanence setup with btrfs subvolumes:

**Subvolumes:**
- `root` - Rolled back on every boot (unless resuming from hibernation)
- `persist` - Persistent storage for important data
- `nix` - Nix store (persistent, with noatime)

**Boot Process (`modules/impermanence.nix`):**
1. Checks for hibernation image in swap to avoid data loss
2. If not hibernating: moves old root to timestamped backup, creates fresh root
3. Auto-deletes root backups older than 30 days
4. Mounts persist subvolume with `neededForBoot = true`

**Persistence Configuration (`modules/persist.nix`):**
- System directories: logs, bluetooth, NetworkManager, flatpak, libvirt, nordvpn
- User directories: Desktop, Downloads, .dotfiles, .ssh, .gnupg, etc.
- Explicitly lists files/dirs to survive reboots

### Desktop Environment: Qtile

Qtile configuration is modular (`home/configs/qtile/`):
- `config.py` - Main configuration entry point
- `modules/` - Separated concerns:
  - `get_theme.py` - Theme loading (integrates with wallust)
  - `groups.py` - Workspace definitions
  - `keys.py` - Keybindings
  - `layouts.py` - Window layouts
  - `screens.py` - Multi-monitor setup
  - `widgets.py` - Status bar widgets
  - `hooks.py` - Event hooks
  - `scratchpads.py` - Dropdown terminal definitions

Qtile uses custom scripts in `home/configs/qtile/scripts/` for:
- Screenshot capture (grim/slurp)
- Clipboard management (cliphist)
- Power management
- Volume/brightness control
- Wallpaper management (variety integration)

The Qtile package uses flake inputs to track upstream git repos for both qtile and qtile-extras.

### Services Configuration

**MongoDB (`modules/mongodb.nix`):**
- Enabled with authentication
- Root password stored in `/persist/mongodb_password`
- Binds to all interfaces (0.0.0.0)
- Data persisted in `/var/db`

**n8n Workflow Automation (`modules/n8n.nix`):**
- Runs behind nginx reverse proxy with self-signed SSL
- Connects to MongoDB with credentials from `/persist/n8n_mongodb_password`
- Accessible at `https://<hostname>.local:443`
- Two setup services run before n8n starts:
  - `n8n-db-setup` - Generates MongoDB connection string
  - `n8n-ssl-setup` - Creates self-signed certificate if missing
- Data persisted in `/var/lib/n8n`

### Home Manager Integration

Home Manager is integrated at the system level (`modules/users.nix`):
- User configuration imported from `home/home.nix`
- Uses `extraSpecialArgs` to pass inputs, username, hostname
- Enables declarative dotfile management

Home configuration structure:
- `home/programs/` - Program-specific configs (fastfetch, kitty, zsh)
- `home/system/` - System-wide settings (gtk, default apps)
- `home/configs/` - Config files sourced to .config (ohmyposh, wallust, qtile, rofi, etc.)

## Adding a New Host

1. Create `hosts/<hostname>/configuration.nix` with basic settings
2. Generate hardware config: `nixos-generate-config --root /mnt`
3. Add btrfs mount options to `hardware-configuration.nix` (see README.md)
4. Add host entry to `hosts/default.nix` in `hostConfigs`
5. Choose desktop environment by uncommenting one option
6. Add hostname to `flake.nix` outputs with appropriate `specialArgs`
7. Build: `sudo nixos-rebuild switch --flake .#<hostname>`

## Adding/Removing Desktop Environments

Edit `hosts/default.nix` in the host's `hostConfigs` section:
- Comment out current desktop (e.g., `# desktops.gnome`)
- Uncomment desired desktop (e.g., `desktops.qtile`)
- Rebuild system

Only one desktop should be active per host.

## Persistence Considerations

When adding new services or configuration:
- Add persistent directories to `modules/persist.nix` under `environment.persistence."/persist"`
- User-specific persistence goes under `users.${username}.directories` or `users.${username}.files`
- For desktop-specific persistence, add to the desktop module (e.g., `desktops/qtile.nix`)
- Remember: anything not listed is lost on reboot

## Password Management

User passwords are stored as hashed files:
1. Generate hash: `mkpasswd -m sha-512 <password>`
2. Save to `/persist/password_hash`
3. User config references this via `hashedPasswordFile`

This prevents password loss during impermanent root rollback.

## Module Organization

Modules in `modules/` are thematic:
- `users.nix` - User creation and home-manager setup
- `impermanence.nix` - Boot-time root rollback logic
- `persist.nix` - Declaration of persistent files/directories
- `packages.nix` - System-wide package lists
- Category modules: `browsers.nix`, `development.nix`, `games.nix`, `media.nix`, etc.
- Service modules: `mongodb.nix`, `n8n.nix`, `nordvpn.nix`, `virtualization.nix`

Desktop modules in `desktops/` configure entire DE stacks with all dependencies.
