# GNOME (Wayland)

> **Module:** [`desktops/gnome.nix`](../../desktops/gnome.nix)
>
> This desktop option runs the full GNOME desktop environment on Wayland. GDM handles login, and GNOME Shell provides window management, the top bar, application launcher, and notifications. Extensions add a dock, tiling assistance, clipboard history, and other quality-of-life features. Nearly all settings are managed declaratively through dconf.

## Screenshots

<!-- Replace the paths below with actual screenshots -->

![Desktop Overview](../images/gnome/desktop-overview.png)
*Full desktop with Dash to Dock, tiled windows, and Qogir theme*

![Application Grid](../images/gnome/application-grid.png)
*Alphabetically sorted application grid*

![Tiling Assistant](../images/gnome/tiling-assistant.png)
*Tiling Assistant window arrangement*

---

## Architecture

```
GDM (Wayland) ─── login ───▶ GNOME Shell
                                 ├── Mutter              (compositor & window manager)
                                 ├── gnome-keyring        (credential storage)
                                 ├── Blueman              (Bluetooth management)
                                 ├── gnome-remote-desktop (RDP server)
                                 ├── Variety              (wallpaper rotation)
                                 └── Extensions
                                      ├── Dash to Dock
                                      ├── Tiling Assistant
                                      ├── Clipboard Indicator
                                      ├── Caffeine
                                      ├── AppIndicator
                                      ├── Alphabetical App Grid
                                      ├── User Themes
                                      └── GNordVPN Local
```

### How It Fits Together

GDM launches a standard GNOME Wayland session. Unlike the Qtile desktops, there is no custom compositor or bar -- GNOME Shell handles all of that natively. The module focuses on:

1. **Declarative dconf settings** that configure the shell, extensions, keybindings, and interface preferences
2. **GNOME extensions** for dock, tiling, clipboard, and other enhancements
3. **GNOME Remote Desktop** for RDP access (port 3389, self-signed TLS)
4. **Custom keybindings** to match the Qtile-style Super+number workspace switching

### Declarative Configuration

Everything is managed through dconf settings in Nix, so the GNOME configuration is fully reproducible:

| Component | Configured via | Source |
|-----------|---------------|--------|
| GDM | `desktops/gnome.nix` | Nix module |
| GNOME Shell | dconf settings in `gnome.nix` | Nix module |
| Extensions | dconf `enabled-extensions` list | Nix module |
| Keybindings | dconf `wm/keybindings` + `media-keys` | Nix module |
| Dash to Dock | dconf `extensions/dash-to-dock` | Nix module |
| Tiling Assistant | dconf `extensions/tiling-assistant` | Nix module |
| GTK theme | `home-manager` GTK settings | Nix module |
| Remote Desktop | dconf `remote-desktop/rdp` + systemd service | Nix module |

### Comparison with Qtile Desktops

| Concern | GNOME | Qtile Wayland | XFCE + Qtile (X11) |
|---------|-------|---------------|-------------------|
| Display server | Wayland | Wayland (wlroots) | X11 |
| Display manager | GDM | SDDM | LightDM |
| Compositor | Mutter (built-in) | Qtile/wlroots (built-in) | Picom (separate) |
| Window management | GNOME Shell + Tiling Assistant | Qtile tiling layouts | Qtile tiling layouts |
| Application launcher | GNOME Activities / App Grid | Rofi | Rofi |
| Clipboard | Clipboard Indicator extension | cliphist | Greenclip |
| Dock/Bar | Dash to Dock (left) | Qtile bar (top) | Qtile bar (top) |
| Notifications | GNOME built-in | dunst | XFCE notification daemon |
| Lock screen | GNOME built-in | swaylock-effects | xflock4 |
| File manager | Nautilus | Thunar | Thunar |
| Remote desktop | GNOME Remote Desktop (RDP) | N/A | N/A |

---

## Theming

The GNOME session uses the **Qogir** shell theme (set via the User Themes extension) with a light GTK theme:

| Setting | Value |
|---------|-------|
| Shell theme | Qogir |
| GTK dark mode | Disabled (light theme) |
| Font | Fira Code Nerd Font, 11pt |
| Clock format | 12-hour with weekday and date |
| Battery | Percentage shown in top bar |
| Hot corners | Disabled |

Wallpapers are managed by **Variety**, which can be controlled via keyboard shortcuts (see below).

---

## Workspaces

GNOME is configured with **dynamic workspaces** (created/destroyed as needed) on the **primary monitor only**.

12 workspaces have dedicated keybindings for switching and moving windows:

| Key | Switch to workspace | Move window to workspace |
|-----|-------------------|------------------------|
| `Super + 1` through `Super + 9` | Workspace 1–9 | `Super + Shift + 1` through `Super + Shift + 9` |
| `Super + 0` | Workspace 10 | `Super + Shift + 0` |
| `Super + -` | Workspace 11 | `Super + Shift + -` |
| `Super + =` | Workspace 12 | `Super + Shift + =` |

The default GNOME `Super + number` shortcuts (which switch to favorite apps in the dock) are disabled to make room for these workspace bindings.

---

## Tiling (Tiling Assistant)

The Tiling Assistant extension provides tiling window management within GNOME:

| Setting | Value |
|---------|-------|
| Window gap | 8px |
| Screen edge gap | 8px |
| Maximize with gap | Yes |
| Tile edit mode | `Super + g` |
| Dynamic keybinding behavior | Mode 2 (directional) |

Use `Super + g` to enter tile edit mode, then arrange windows with keyboard or mouse. Standard GNOME tiling (drag to edges/corners) also works.

---

## Dash to Dock

The dock is configured for quick access to favorite applications:

| Setting | Value |
|---------|-------|
| Position | Left side |
| Multi-monitor | Enabled (dock on all monitors) |
| Icon size | 20px (max) |
| Running indicator | Dashes |
| Hot keys | Disabled |
| Show mounts | No |
| Show trash | No |
| Transparency | Fixed at 80% opacity |

### Favorite Apps (dock order)

1. Zen Browser
2. Google Chrome
3. Mailspring
4. Chrome PWA apps (Notion, Docs)
5. Telegram
6. Caprine (Messenger)
7. Mattermost
8. Discord
9. Chrome PWA (additional)
10. Anytype
11. Remmina
12. Kitty
13. VS Code
14. MongoDB Compass
15. OnlyOffice
16. Annotator
17. OBS Studio
18. Kdenlive
19. Cider (Apple Music)
20. Nautilus

---

## Keyboard Shortcuts

`Super` refers to the Windows/Meta key.

### Window Management

| Shortcut | Action |
|----------|--------|
| `Super + q` | Close focused window |
| `Super + g` | Enter Tiling Assistant edit mode |

### Applications

| Shortcut | Action |
|----------|--------|
| `Super + Enter` | Launch terminal (kitty) |
| `Super + Shift + Enter` | Launch file manager (Nautilus) |
| `Super + Escape` | Lock screen |

### Wallpaper (Variety)

| Shortcut | Action |
|----------|--------|
| `Super + w` | Next random wallpaper |
| `Super + Shift + w` | Previous wallpaper |
| `Alt + f` | Save current wallpaper to favorites |

### Workspaces

| Shortcut | Action |
|----------|--------|
| `Super + 1` – `Super + 9` | Switch to workspace 1–9 |
| `Super + 0` | Switch to workspace 10 |
| `Super + -` | Switch to workspace 11 |
| `Super + =` | Switch to workspace 12 |
| `Super + Shift + 1` – `Super + Shift + 0` | Move window to workspace 1–10 |
| `Super + Shift + -` | Move window to workspace 11 |
| `Super + Shift + =` | Move window to workspace 12 |

Standard GNOME keybindings (not overridden) also remain available, such as `Super` to open Activities, `Super + A` for the app grid, and `Super + L` to lock.

---

## GNOME Remote Desktop (RDP)

The module configures GNOME Remote Desktop for RDP access, useful for headless or remote sessions:

| Setting | Value |
|---------|-------|
| Protocol | RDP (port 3389) |
| Mode | Screen mirroring |
| View-only | No (full control) |
| TLS certificate | `~/.local/share/gnome-remote-desktop/certificates/rdp-tls.crt` |
| TLS key | `~/.local/share/gnome-remote-desktop/certificates/rdp-tls.key` |

The RDP daemon runs as a D-Bus activated systemd user service that starts with the GNOME session. Firewall ports (TCP/UDP 3389) are opened automatically.

---

## Installed Packages

These packages are installed specifically by the GNOME desktop module:

| Package | Purpose |
|---------|---------|
| `gnome-tweaks` | Advanced GNOME settings editor |
| `gnome-calculator` | Calculator app |
| `gnome-remote-desktop` | RDP server for remote access |
| `openssl` | TLS certificate generation for RDP |

### GNOME Extensions

| Extension | Purpose |
|-----------|---------|
| **Dash to Dock** | Persistent dock on the left side |
| **AppIndicator** | System tray icon support |
| **Caffeine** | Prevent screen from sleeping |
| **Clipboard Indicator** | Clipboard history manager |
| **Alphabetical App Grid** | Sort application grid alphabetically |
| **Tiling Assistant** | Tiling window management with gaps |
| **User Themes** | Custom shell theme support (Qogir) |
| **GNordVPN Local** | NordVPN status indicator |

Additional packages come from the shared system modules (`modules/packages.nix`, etc.).

---

## Persistence

The following paths survive reboots via the impermanence module:

| Path | Purpose |
|------|---------|
| `~/.config/gnome-initial-setup-done` | Prevents first-run wizard on each boot |
| `~/.local/share/gnome-remote-desktop` | RDP TLS certificates and settings |

---

## Customization Tips

- **Change wallpaper source:** Configure Variety through its preferences or use `Super + w` for next wallpaper
- **Install more extensions:** Add to the `environment.systemPackages` list in `gnome.nix` and enable in the `enabled-extensions` dconf list
- **Edit keybindings:** Modify the `dconf.settings` blocks in `gnome.nix`, or use GNOME Settings > Keyboard > Shortcuts (changes made through the UI will not persist across reboots unless added to the Nix config)
- **Change dock position/size:** Edit the `dash-to-dock` dconf section in `gnome.nix`
- **Adjust tiling gaps:** Edit the `tiling-assistant` dconf section in `gnome.nix`
- **Change shell theme:** Update the `user-theme` name in dconf settings and ensure the theme package is installed
- **Modify favorite apps:** Edit the `favorite-apps` list in the `org/gnome/shell` dconf section
- **Configure RDP credentials:** Use `grdctl rdp set-credentials <username> <password>` after logging in
- **Switch to this desktop:** In `hosts/default.nix`, set `desktops.gnome` in your host's config list and rebuild
