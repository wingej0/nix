# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Deploy Commands

```bash
# Build and switch to new configuration (main command)
sudo nixos-rebuild switch --flake .#darter-pro

# Build without switching (test build)
sudo nixos-rebuild build --flake .#darter-pro

# Build for VM host
sudo nixos-rebuild switch --flake .#nix-vm

# Update flake inputs
nix flake update

# Check flake syntax
nix flake check
```

## Architecture

This is a NixOS Flake configuration with impermanence (root filesystem resets on reboot).

### Entry Point Flow

`flake.nix` defines two hosts (`darter-pro`, `nix-vm`) and passes `hostname` via `specialArgs` to `hosts/default.nix`, which acts as a **module dispatcher** - it selects which modules to import based on hostname.

### Module Composition Pattern

```
flake.nix
  └─> hosts/default.nix (dispatcher)
        ├─> hosts/<hostname>/configuration.nix (host-specific base config)
        ├─> desktops/<desktop>.nix (desktop environment - currently gnome)
        ├─> modules/*.nix (shared system modules)
        └─> home/home.nix (Home Manager - user-level config)
```

### Key Architectural Decisions

1. **Impermanence**: Uses BTRFS subvolumes - root resets each boot, `/persist` and `/nix` survive. User password must be persisted in `/persist/password_hash`. See `modules/impermanence.nix` and `modules/persist.nix`.

2. **Desktop Switching**: Comment/uncomment desktop imports in `hosts/default.nix` to change desktop environments.

3. **Module Categories**:
   - `desktops/` - Mutually exclusive DE configurations
   - `modules/` - Composable system features (packages, services, etc.)
   - `home/` - User-level configs managed by Home Manager

4. **Host Differentiation**: `darter-pro` includes System76 drivers and more modules; `nix-vm` is a minimal subset for testing.

### Important Files

- `modules/persist.nix` - Defines what survives reboots under impermanence
- `modules/users.nix` - User account configuration with persisted password
- `home/home.nix` - Home Manager entry point, imports user programs/configs
- `home/configs/` - Raw dotfiles symlinked to ~/.config
