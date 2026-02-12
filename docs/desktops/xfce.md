# XFCE + Qtile (X11)

> **Module:** [`desktops/xfce.nix`](../../desktops/xfce.nix)
>
> This desktop option pairs the XFCE session with the Qtile tiling window manager running on X11. XFCE provides system services (keyring, Blueman, session management), while Qtile handles all window management, keybindings, and the status bar.

## Screenshots

<!-- Replace the paths below with actual screenshots -->

![Desktop Overview](../images/xfce/desktop-overview.png)
*Full desktop with Qtile bar, tiled windows, and wallust-generated theme*

![Bar Widgets](../images/xfce/bar-widgets.png)
*Status bar showing system monitors, workspaces, and quick-launch icons*

![Rofi Launcher](../images/xfce/rofi-launcher.png)
*Rofi application launcher*

![Scratchpad Terminal](../images/xfce/scratchpad-terminal.png)
*Floating scratchpad terminal (Alt+Enter)*

---

## Architecture

```
XFCE Session
 ├── gnome-keyring         (credential storage)
 ├── Blueman               (Bluetooth management)
 ├── xfconf                (XFCE settings storage)
 └── Qtile (window manager)
      ├── Picom             (compositor: shadows, rounded corners, fading)
      ├── Rofi              (application launcher)
      ├── Greenclip         (clipboard manager daemon)
      ├── Variety           (wallpaper rotation)
      └── wallust           (generates color themes from wallpaper)
```

### How It Fits Together

The Nix module configures XFCE as the desktop session but **disables** XFCE's own window manager (`enableXfwm = false`) and desktop (`noDesktop = true`). The XFCE session is then configured via `xfconf` to launch Qtile on startup instead:

```nix
xfconf.settings = {
    xfce4-session = {
        "sessions/Failsafe/Client0_Command" = [ "qtile" "start" ];
    };
};
```

This gives you XFCE's reliable session management, keyring integration, and LightDM display manager, combined with Qtile's tiling power.

### Declarative Configuration

Everything in this desktop is **fully declarative** through Nix:

| Component | Configured via | Source files |
|-----------|---------------|--------------|
| XFCE session | `desktops/xfce.nix` (xfconf settings) | Nix module |
| Qtile | `home/configs/qtile/` (Python config) | Symlinked to `~/.config/qtile` |
| Picom | `home/configs/picom/picom.conf` | Symlinked to `~/.config/picom` |
| Rofi | `home/configs/rofi/` | Symlinked to `~/.config/rofi` |
| Greenclip | systemd user service in `xfce.nix` | Nix module |

XFCE's own settings (stored in `~/.config/xfce4/xfconf`) are persisted across reboots via the impermanence module but are **not** declaratively managed beyond the session startup config. Any changes made through XFCE Settings will survive reboots.

---

## Theming

Colors are **dynamically generated** from the current wallpaper using [wallust](https://codeberg.org/explosion-mental/wallust). The theme pipeline works like this:

1. **Variety** selects a wallpaper and saves it to `~/Pictures/current_wallpaper.jpg`
2. **wallust** processes the wallpaper and generates a `colors.json` file
3. **Qtile** reads `~/.cache/qtile/colors.json` on startup to theme the bar, borders, and widgets
4. **Rofi** also reads wallust-generated colors from `~/.cache/rofi/`

This means the entire desktop theme shifts automatically whenever the wallpaper changes.

### Picom Compositor

Picom provides visual polish on X11:

- **Rounded corners:** 15px radius on all windows (except desktop and Qtile internal windows)
- **Shadows:** Enabled with radius 7, offset -7
- **Fading:** Enabled for window open/close transitions
- **Backend:** EGL with VSync
- **Menus:** Popup and dropdown menus rendered at 80% opacity

---

## Workspaces

14 workspaces are available, each with an icon label and a default layout:

| Key | Icon | Default Layout |
|-----|------|----------------|
| `1` |  | MonadTall |
| `2` |  | Max |
| `3` |  | Spiral |
| `4` |  | MonadTall |
| `5` |  | MonadWide |
| `6` |  | Max |
| `7` |  | MonadTall |
| `8` |  | MonadTall |
| `9` |  | MonadTall |
| `0` |  | MonadTall |
| `-` |  | MonadTall |
| `=` |  | MonadTall |
| `y` |  | MonadTall |
| `u` |  | MonadTall |

Switch to a workspace with `Super + <key>`. Move the focused window to a workspace with `Super + Shift + <key>`.

---

## Layouts

Four tiling layouts are available, cycled with `Super + Tab`:

| Layout | Description |
|--------|-------------|
| **MonadTall** | One main window on the left, stack on the right |
| **MonadWide** | One main window on top, stack on the bottom |
| **Max** | Fullscreen the focused window (others hidden behind) |
| **Spiral** | Fibonacci spiral arrangement (70/30 main pane ratio) |

All layouts use an **8px margin** between windows and a **4px border** (focused border color from wallust `color11`, unfocused from `color0`).

---

## Keyboard Shortcuts

`Super` refers to the Windows/Meta key. `Alt` refers to the left Alt key.

### Window Management

| Shortcut | Action |
|----------|--------|
| `Super + q` | Close focused window |
| `Super + f` | Toggle fullscreen |
| `Super + Shift + f` | Flip layout (swap main/stack side) |
| `Super + Shift + Space` | Toggle floating for focused window |
| `Super + r` | Reset all window sizes in current group |
| `Super + Tab` | Cycle to next layout |

### Window Focus

| Shortcut | Action |
|----------|--------|
| `Super + h` / `Super + Left` | Focus window left |
| `Super + l` / `Super + Right` | Focus window right |
| `Super + k` / `Super + Up` | Focus window above |
| `Super + j` / `Super + Down` | Focus window below |

### Window Movement

| Shortcut | Action |
|----------|--------|
| `Super + Shift + h` / `Super + Shift + Left` | Move window left |
| `Super + Shift + l` / `Super + Shift + Right` | Move window right |
| `Super + Shift + k` / `Super + Shift + Up` | Move window up |
| `Super + Shift + j` / `Super + Shift + Down` | Move window down |

### Window Resizing

| Shortcut | Action |
|----------|--------|
| `Super + Ctrl + h` / `Super + Ctrl + Left` | Shrink window |
| `Super + Ctrl + l` / `Super + Ctrl + Right` | Grow window |
| `Super + Ctrl + k` / `Super + Ctrl + Up` | Grow window (vertical) |
| `Super + Ctrl + j` / `Super + Ctrl + Down` | Shrink window (vertical) |

### Applications

| Shortcut | Action |
|----------|--------|
| `Super + Enter` | Launch terminal (kitty) |
| `Super + Shift + Enter` | Launch file manager (Thunar) |
| `Super + Space` | Open Rofi application launcher |
| `Super + b` | Launch Firefox |
| `Super + m` | Launch Mailspring |
| `Super + v` | Open clipboard manager (Greenclip via Rofi) |
| `Super + Escape` | Lock screen (xflock4) |

### Wallpaper (Variety)

| Shortcut | Action |
|----------|--------|
| `Super + w` | Next random wallpaper |
| `Super + Shift + w` | Previous wallpaper |
| `Ctrl + Alt + w` | Open wallpaper selector |
| `Alt + f` | Save current wallpaper to favorites |
| `Super + x` | Kill Variety |

### Scratchpads

Floating dropdown windows that toggle on/off:

| Shortcut | Scratchpad |
|----------|------------|
| `Alt + Enter` | Terminal (kitty) |
| `Alt + v` | Volume control (pavucontrol) |
| `Super + a` | Angular terminal |
| `Super + n` | Notebook terminal |

All scratchpads appear centered at 80% width/height.

### Monitor Control

| Shortcut | Action |
|----------|--------|
| `Super + i` | Focus monitor 1 |
| `Super + o` | Focus monitor 2 |
| `Super + p` | Focus monitor 3 |
| `Super + ,` | Focus next monitor |
| `Super + .` | Focus previous monitor |

### Workspace Navigation

| Shortcut | Action |
|----------|--------|
| `Alt + Tab` | Next workspace |
| `Alt + Shift + Tab` | Previous workspace |

### Media Keys

| Key | Action |
|-----|--------|
| `Volume Up` | Raise volume (wpctl, 3% steps) |
| `Volume Down` | Lower volume (wpctl, 3% steps) |
| `Mute` | Toggle mute |
| `Play/Pause` | Toggle playback (playerctl) |
| `Next` | Next track |
| `Previous` | Previous track |
| `Stop` | Stop playback |
| `Brightness Up` | Increase brightness 5% |
| `Brightness Down` | Decrease brightness 5% |

### System

| Shortcut | Action |
|----------|--------|
| `Super + Shift + q` | Log out (Qtile shutdown) |
| `Super + Shift + r` | Restart Qtile (preserves session) |

### Mouse Bindings

| Binding | Action |
|---------|--------|
| `Super + Left Click Drag` | Move floating window |
| `Super + Right Click Drag` | Resize floating window |
| `Super + Middle Click` | Bring window to front |

---

## Status Bar

The Qtile bar sits at the top of each screen (30px tall, 90% opacity, semi-transparent black background). Widgets are organized into colored pill-shaped groups using `RectDecoration`:

### Bar Layout (left to right)

| Section | Widgets | Color |
|---------|---------|-------|
| Logo | Qtile icon + "Qtile" label (click opens Rofi) | Dark (`color11`) |
| System | Memory %, CPU %, Temperature | Light (`color15`) |
| Audio/Display | Brightness, Volume | Light (`color15`) |
| Layout | Current layout icon + name | Mid (`color1`) |
| Caps/Num Lock | Indicator | Default |
| **Center** | Workspace icons (GroupBox) | Dark (`color11`) |
| Media | Now playing (Mpris2, 175px wide) | Default |
| Updates | Package update count | Mid (`color1`) |
| Battery | Percentage + power profile (click to change) | Light (`color15`) |
| Quick Launch | Gemini, wallpaper selector, Thunar, clipboard, screenshot | Light (`color15`) |
| Network | Bluetooth icon, WiFi icon (right-click opens nmtui) | Light (`color15`) |
| Clock | Date + time (click opens XFCE session logout) | Dark (`color11`) |

---

## Installed Packages

These packages are installed specifically by the XFCE desktop module:

| Package | Purpose |
|---------|---------|
| `peek` | GIF screen recorder |
| `rofi` | Application launcher |
| `brightnessctl` | Screen brightness control |
| `python3` | Required for Qtile |
| `greenclip` | Clipboard manager (X11) |
| `file-roller` | Archive manager |
| `playerctl` | Media player control |

Additional packages come from the shared system modules (`modules/packages.nix`, etc.).

---

## Persistence

The following paths survive reboots via the impermanence module:

| Path | Purpose |
|------|---------|
| `~/.local/share/qtile` | Qtile state data |
| `~/.cache/qtile` | wallust-generated theme (colors.json) |
| `~/.cache/rofi` | wallust-generated Rofi theme |
| `~/.config/xfce4/xfconf` | XFCE settings made through the UI |

---

## Customization Tips

- **Change wallpaper source:** Configure Variety through its selector (`Ctrl + Alt + w`)
- **Edit keybindings:** Modify `home/configs/qtile/modules/keys.py`
- **Add/remove workspaces:** Edit `home/configs/qtile/modules/groups.py`
- **Change layouts:** Edit `home/configs/qtile/modules/layouts.py`
- **Modify bar widgets:** Edit `home/configs/qtile/modules/widgets.py`
- **Adjust picom effects:** Edit `home/configs/picom/picom.conf`
- **Switch to this desktop:** In `hosts/default.nix`, set `desktops.xfce` in your host's config list and rebuild
