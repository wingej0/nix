# Plan: Add Niri + DankMaterialShell Desktop Option

## Context

Add a new desktop environment option using **niri** (scrollable tiling Wayland compositor) with **DankMaterialShell** (DMS — a complete desktop shell built with Quickshell & Go). This replaces the previous plan to use noctalia-shell. DMS provides panels, notifications, lock screen, app launcher, clipboard manager, polkit agent, and — critically — **dynamic wallpaper-based theming via matugen** that automatically propagates to GTK, Qt, terminals, and editors.

This replaces the current **wallust** color pipeline with DMS's built-in **matugen** integration, which generates Material Design 3 color palettes from wallpapers and applies them across the entire desktop. No more manual template wiring.

Uses the **tuigreet** greeter (same as qtile) and DMS's built-in lock screen / notifications (replacing gtklock and dunst for this desktop).

---

## Implementation Progress

### Step 1: Add flake inputs (`flake.nix`) — DONE

Added three inputs after `zen-browser`:
- `niri` → `github:sodiboo/niri-flake`
- `dms` → `github:AvengeMedia/DankMaterialShell/stable`
- `dms-plugin-registry` → `github:AvengeMedia/dms-plugin-registry`

All follow `nixpkgs`. Lock file updated and `nix flake check` passes.

### Step 2: Create `desktops/niri.nix` — DONE

New desktop module created. Key discoveries during implementation:

- **`programs.niri.settings` is a home-manager option**, not a NixOS option. The NixOS module (`inputs.niri.nixosModules.niri`) only provides `programs.niri.enable` and `programs.niri.package`. Settings go inside `home-manager.users.${username}`.
- **DMS niri module conflicts with explicit binds** — the DMS `homeModules.niri` injects its own keybinds into `programs.niri.settings.binds`, so our overrides need `lib.mkForce` on the `action` attribute to avoid "defined multiple times" errors.
- **`enableKeybinds` and `includes.enable` conflict** — DMS warns against using both. Since we use `niri.includes` with `filesToInclude = [ ... "binds" ... ]`, we dropped `enableKeybinds` and only set `enableSpawn = true`.
- **Parameterless action syntax is broken with `null`** — setting `action.focus-column-left = null` renders literally as `focus-column-left null;` in KDL, which niri rejects. The correct niri-flake representation for zero-argument actions is still TBD. For now, **parameterless actions are left as niri/DMS defaults** and only actions with arguments (spawn, focus-workspace, move-column-to-workspace, set-column-width/height) are overridden.
- **DMS lock command** is `dms ipc call lock lock` (confirmed from DMS IPC docs at danklinux.com). Used in the `lock-before-sleep` systemd service.
- **`matugen` is in nixpkgs** (version 3.1.0) — no extra flake input needed.
- **DMS module paths** (verified via `nix eval`):
  - `inputs.dms.homeModules.dank-material-shell`
  - `inputs.dms.homeModules.niri`
  - `inputs.dms-plugin-registry.homeModules.default`
- **Niri config is manual** (`~/.config/niri/config.kdl`) — DMS `homeModules.niri` is disabled for now so we can tinker without rebuilds. Once settings are dialed in, move back to `programs.niri.settings`.

### Step 3: Register in `hosts/default.nix` — DONE

- Added `niri = ./../desktops/niri.nix;` to the desktops attrset.
- Swapped darter-pro from `desktops.cosmic` to `desktops.niri` (cosmic commented out).
- `nix flake check` passes for all four host configurations.

### Step 4: Build & Boot — DONE

- `nixos-rebuild build --flake .#darter-pro` succeeds.
- Booted into niri + DMS successfully. tuigreet → niri session → DMS launches.

### Step 5: Post-boot fixes (this session) — DONE

- **Cider AppImage wouldn't launch** — Electron was defaulting to X11 Ozone platform. Fixed by adding `ELECTRON_OZONE_PLATFORM_HINT = "auto"` to `environment.sessionVariables` in `niri.nix`.
- **DMS wallpaper settings not persisting reboots** — wallpaper/session state lives in `~/.local/state/DankMaterialShell/session.json`, which wasn't persisted. Added `.local/state/DankMaterialShell` and `.cache/DankMaterialShell` to persistence.
- **DMS launcher not bound** — default config had `Mod+D` → fuzzel. Removed that bind and added `Mod+Space` → `dms ipc call launcher toggle` in `~/.config/niri/config.kdl`.
- **Kitty colors hardcoded (Dracula)** — stripped all color/tab settings from `home/programs/kitty.nix` and added `include dank-theme.conf` + `include dank-tabs.conf` so kitty uses DMS/matugen wallpaper-matched colors dynamically.
- **GTK color-scheme was prefer-light** — DMS runs dark mode. Added `lib.mkForce` overrides in `niri.nix` home-manager block: `dconf color-scheme = "prefer-dark"` and `gtk-application-prefer-dark-theme = 1`.
- **Zen Browser transparency** — transparent-zen mod was showing niri's focus ring colors (blue `#7fc8ff` when active, dark grey `#505050` when inactive) instead of transparent. Root cause: niri draws focus ring as a solid rectangle *behind* windows by default, which bleeds through semitransparent windows. Fixed with two changes:
  1. **Niri window rule** (`~/.config/niri/config.kdl`): Added `draw-border-with-background false` for `app-id=r#"^zen"#` so the focus ring draws *around* the window instead of behind it.
  2. **Zen userChrome.css** (`~/.zen/.../chrome/userChrome.css`): Zen Browser reverts to an opaque background when the window loses focus (`:-moz-window-inactive`). Added CSS overrides to force `background-color: transparent` on `#main-window`, `#zen-main-app-wrapper`, `#browser`, `#navigator-toolbox`, `#zen-toolbar-background`, `#tabbrowser-tabpanels`, and `#appcontent` in the inactive state.
- **Kitty transparency** — same `draw-border-with-background` issue. Added matching niri window rule for `app-id="kitty"`.

### Step 6: Dynamic focus ring colors from DMS — IN PROGRESS

Goal: make niri's focus ring/border colors follow the DMS/matugen wallpaper palette instead of being hardcoded.

**Discovery:** DMS already generates `~/.config/niri/dms/colors.kdl` with the correct Material Design 3 colors (primary for active, outline for inactive, error for urgent). This file auto-updates on wallpaper changes. It wraps colors in `layout {}`, `recent-windows {}`, etc. blocks.

**Problem:** Niri's `include` directive requires **v25.11+**, but the flake's `niri-stable` is v25.08. The `niri-unstable` input (2026-02-17) supports it.

**Fix applied to `desktops/niri.nix`:**
```nix
nixpkgs.overlays = [ inputs.niri.overlays.niri ];
programs.niri.package = pkgs.niri-unstable;
```

`nix flake check` passes. **Needs `nixos-rebuild boot` + reboot.**

**After reboot, still TODO:**
1. Add `include "dms/colors.kdl"` to the top of `~/.config/niri/config.kdl`
2. Remove the hardcoded `focus-ring {}` and `border {}` blocks from the `layout` section (DMS colors.kdl provides them)
3. Verify colors update dynamically when changing wallpaper

---

## Files Modified

| File | Change |
|------|--------|
| `flake.nix` | Added `niri`, `dms`, and `dms-plugin-registry` inputs |
| `flake.lock` | Updated with locked revisions for new inputs |
| `desktops/niri.nix` | **New file** — full desktop module |
| `hosts/default.nix` | Added `niri` to desktops map, activated on darter-pro |
| `home/programs/kitty.nix` | Removed hardcoded Dracula colors, added DMS theme includes |
| `home/configs/dunst/dunstrc` | Changed icon theme to Qogir |
| `modules/communication.nix` | Added `gcr` to dbus packages |
| `~/.config/niri/config.kdl` | Added `draw-border-with-background false` window rules for Zen + Kitty |
| `~/.zen/.../chrome/userChrome.css` | **New file** — forces transparent background on inactive Zen windows |

---

## Current Keybind Status

Keybinds are managed manually in `~/.config/niri/config.kdl` (not via nix).

**Custom binds set:**
- `Mod+Return` (kitty), `Mod+Shift+Return` (thunar), `Mod+B` (firefox)
- `Mod+Space` — DMS launcher
- `Mod+Escape` (DMS lock), `Ctrl+Alt+Delete` (DMS power menu)
- Workspaces, resize, media keys — via niri config defaults + manual edits

---

## Items Still To Address

### Pre-commit

- **ZSH wallust guard** (`home/programs/zsh.nix:17`) — `cat ~/.cache/wallust/sequences` will error on niri+DMS since that file won't exist. Add a guard: `[[ -f ~/.cache/wallust/sequences ]] && cat ~/.cache/wallust/sequences`.
- **`wlr-randr` aliases** (`home/programs/zsh.nix:24-25`) — the `office` and `laptop` aliases use `wlr-randr` which doesn't work with niri. Make conditional or replace with `niri msg output` equivalents.

### After further testing

- **Test lock-before-sleep** — verify `dms ipc call lock lock` works from the systemd service.
- **Parameterless keybinds** — investigate correct niri-flake syntax for zero-argument actions if we move config back to nix.
- **GTK theme conflict** (`home/system/gtk.nix`) — Qogir theme is still set. DMS generates dynamic GTK CSS via matugen. Monitor for visual glitches; may need to make desktop-conditional.
- **Display layout** — configure multi-monitor via niri settings.

---

## Theming Migration: wallust → matugen (via DMS)

Current pipeline:
```
Variety → set_wallpaper script → wallust run → JSON/rasi/CSS templates → qtile/rofi/wlogout/terminal
```

New pipeline with DMS:
```
DMS wallpaper manager → matugen → Material Design 3 palette → GTK/Qt/terminals/editors/shell (all automatic)
```

Kitty now uses `include dank-theme.conf` + `include dank-tabs.conf` for dynamic colors.

Note: wallust and Variety remain installed system-wide (in `modules/packages.nix`) for other desktops like qtile and GNOME. They just won't be used when running niri + DMS.

---

## Verification Checklist

1. [x] `nix flake check` — flake evaluates without errors
2. [x] `nixos-rebuild build --flake .#darter-pro` — build succeeds
3. [x] `nixos-rebuild boot --flake .#darter-pro` + reboot
4. [x] tuigreet appears → select niri session → DMS launches
5. [x] Panel visible, change wallpaper → colors update across shell + GTK + terminal
6. [ ] Lock screen works (`Mod+Escape` and lock-before-sleep)
7. [ ] Notifications work
8. [ ] Clipboard manager works
9. [ ] Screenshots (grim/slurp/swappy) still work
10. [x] App launcher works (`Mod+Space` → DMS launcher)
11. [x] Cider AppImage launches on Wayland
12. [x] Zen Browser transparency works (active + inactive, via niri window rule + userChrome.css)
13. [x] Kitty transparency works (via niri window rule)
14. [x] Kitty uses dynamic DMS/matugen colors
15. [ ] Niri focus ring follows DMS wallpaper colors (needs reboot to niri-unstable, then add `include "dms/colors.kdl"`)
