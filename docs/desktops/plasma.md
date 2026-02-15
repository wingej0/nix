# KDE Plasma 6 (Wayland)

> **Module:** [`desktops/plasma.nix`](../../desktops/plasma.nix)
>
> This desktop option runs KDE Plasma 6 on Wayland with SDDM as the display manager. Configuration is managed declaratively through [plasma-manager](https://github.com/nix-community/plasma-manager), a Home Manager module that controls Plasma settings from Nix. This configuration is a **work in progress** -- keybindings and workspace settings are in place, but many areas remain at Plasma defaults.

## Screenshots

<!-- Replace the paths below with actual screenshots -->

![Desktop Overview](../images/plasma/desktop-overview.png)
*Plasma desktop with floating top panel and Breeze Dark theme*

---

## Architecture

```
SDDM (Wayland) ─── login ───▶ KDE Plasma Shell
                                  ├── KWin              (compositor & window manager)
                                  ├── Plasma Panel      (floating top bar)
                                  ├── KRunner           (application launcher)
                                  ├── Dolphin           (file manager)
                                  ├── Variety           (wallpaper rotation)
                                  └── KDE services      (keyring, notifications, etc.)
```

### How It Fits Together

SDDM launches a Plasma Wayland session. The desktop is configured declaratively via **plasma-manager**, which translates Nix settings into KDE configuration files. The `overrideConfig = true` setting ensures that Nix-declared settings always take precedence -- any changes made through KDE System Settings for managed options will be reverted on the next rebuild.

Settings **not** covered by the Nix config remain at Plasma defaults and can be changed imperatively through System Settings.

### Declarative Configuration

| Component | Configured via | Source |
|-----------|---------------|--------|
| SDDM | `desktops/plasma.nix` | Nix module |
| Plasma workspace | plasma-manager `workspace` settings | Nix module |
| Panel | plasma-manager `panels` config | Nix module |
| Keybindings | plasma-manager `shortcuts` + `hotkeys.commands` | Nix module |
| KWin settings | plasma-manager `configFile` (kwinrc) | Nix module |
| Input settings | plasma-manager `configFile` (kcminputrc) | Nix module |

### Comparison with Other Desktops

| Concern | KDE Plasma | GNOME | Qtile Wayland |
|---------|-----------|-------|---------------|
| Display server | Wayland | Wayland | Wayland (wlroots) |
| Display manager | SDDM | GDM | SDDM |
| Compositor | KWin | Mutter | Qtile/wlroots |
| Config management | plasma-manager (Nix) | dconf (Nix) | Python config files |
| Application launcher | KRunner | GNOME Activities | Rofi |
| File manager | Dolphin | Nautilus | Thunar |
| Window switching | Cover Switch (Alt+Tab) | GNOME switcher | Qtile focus keys |

---

## Theming

| Setting | Value |
|---------|-------|
| Workspace theme | Breeze Dark |
| Color scheme | BreezeDark |
| Wallpaper | `~/Pictures/current_wallpaper.jpg` (managed by Variety) |
| Cursor theme | Bibata-Modern-Classic |
| Blur | Enabled (KWin plugin) |

---

## Workspaces

The desktop is configured with **9 static workspaces** arranged in a **3-row grid**.

12 workspace keybindings are defined (workspaces 10-12 can be added by increasing the workspace count):

| Key | Switch to workspace | Move window to workspace |
|-----|-------------------|------------------------|
| `Meta + 1` through `Meta + 9` | Workspace 1-9 | `Meta + Shift + 1` through `Meta + Shift + 9` |
| `Meta + 0` | Workspace 10 | `Meta + Shift + 0` |
| `Meta + -` | Workspace 11 | `Meta + Shift + -` |
| `Meta + =` | Workspace 12 | `Meta + Shift + =` |

---

## Window Management (KWin)

| Setting | Value |
|---------|-------|
| Focus policy | Focus follows mouse |
| Auto-raise | Enabled (focused window raises automatically) |
| Next focus prefers mouse | Enabled |
| Task switcher (Alt+Tab) | Cover Switch layout |
| Blur | Enabled |
| XWayland scale | 1x |

---

## Panel

A single **floating panel** is positioned at the **top** of the screen. No additional widgets or customizations are declared beyond the Plasma defaults for a top panel.

---

## Keyboard Shortcuts

`Meta` refers to the Windows/Super key.

### Applications

| Shortcut | Action |
|----------|--------|
| `Meta + Enter` | Launch terminal (kitty) |
| `Meta + Shift + Enter` | Launch file manager (Dolphin) |
| `Meta` | Open KRunner (application launcher) |
| `Meta + Escape` | Lock session |

### Window Management

| Shortcut | Action |
|----------|--------|
| `Meta + Q` | Close window |
| `Meta + D` | Overview (expose all windows) |

### Wallpaper (Variety)

| Shortcut | Action |
|----------|--------|
| `Meta + W` | Next random wallpaper |
| `Meta + Shift + W` | Previous wallpaper |

### Workspaces

| Shortcut | Action |
|----------|--------|
| `Meta + 1` – `Meta + 9` | Switch to workspace 1-9 |
| `Meta + 0` / `Meta + -` / `Meta + =` | Switch to workspace 10/11/12 |
| `Meta + Shift + 1` – `Meta + Shift + 0` | Move window to workspace 1-10 |
| `Meta + Shift + -` / `Meta + Shift + =` | Move window to workspace 11/12 |

---

## Input Settings

| Setting | Value |
|---------|-------|
| Touchpad natural scrolling | Enabled |
| Cursor theme | Bibata-Modern-Classic |

---

## Persistence

The following paths survive reboots via the impermanence module:

| Path | Purpose |
|------|---------|
| `~/.config/kwinoutputconfig.json` | Monitor/display configuration |

Other Plasma settings are managed declaratively by plasma-manager and regenerated on each rebuild, so they do not need persistence entries.

---

## Work in Progress

This Plasma configuration covers the basics but has not been fleshed out to the same degree as the Qtile or GNOME desktops. Areas that may be expanded in the future include:

- Additional panel widgets and layout customization
- Window rules and tiling configuration
- Notification settings
- Additional application shortcuts
- Theme and appearance refinements beyond Breeze Dark
- Persistence entries for any imperative settings worth keeping

---

## Customization Tips

- **Change theme/appearance:** Edit the `workspace` block in `plasma.nix`, or use KDE System Settings for options not managed by Nix (note: `overrideConfig = true` means Nix-managed settings will overwrite manual changes on rebuild)
- **Add keybindings:** Add entries to the `shortcuts` or `hotkeys.commands` sections in `plasma.nix`
- **Change workspace count:** Edit `kwinrc.Desktops.Number` in the `configFile` section
- **Adjust focus behavior:** Edit the `kwinrc.Windows` settings in `configFile`
- **Add panel widgets:** Expand the `panels` configuration in `plasma.nix` (see [plasma-manager docs](https://github.com/nix-community/plasma-manager))
- **Change wallpaper source:** Configure Variety through its preferences
- **Switch to this desktop:** In `hosts/default.nix`, set `desktops.plasma` in your host's config list and rebuild
