# Qtile (Wayland)

> **Module:** [`desktops/qtile.nix`](../../desktops/qtile.nix)
>
> This desktop option runs Qtile as a standalone Wayland compositor. There is no traditional desktop environment underneath -- Qtile handles window management, compositing, and input directly through wlroots. Supporting services (notifications, lock screen, power menu, clipboard, display management) are provided by standalone Wayland-native tools.

## Screenshots

<!-- Replace the paths below with actual screenshots -->

![Desktop Overview](../images/qtile-wayland/desktop-overview.png)
*Full desktop with Qtile bar, tiled windows, and wallust-generated theme*

![wlogout Power Menu](../images/qtile-wayland/wlogout.png)
*wlogout power menu (Ctrl+Alt+Delete)*

![gtklock](../images/qtile-wayland/gtklock.png)
*gtklock lock screen with wallpaper background*

![Screenshot Workflow](../images/qtile-wayland/screenshot-workflow.png)
*Screenshot via grim/slurp with Swappy annotation editor*

![Dunst Notification](../images/qtile-wayland/dunst-notification.png)
*Dunst notification popup*

---

## Architecture

```
tuigreet ─── login ───▶ Qtile (wlroots compositor)
                           ├── kanshi          (automatic display profile switching)
                           ├── dunst           (notification daemon)
                           ├── cliphist        (clipboard history via wl-clipboard)
                           ├── polkit-gnome    (authentication agent)
                           ├── Variety         (wallpaper rotation)
                           ├── wallust         (color theme from wallpaper)
                           ├── Rofi            (application launcher)
                           ├── gtklock         (lock screen)
                           └── wlogout         (power menu)
```

### How It Fits Together

Unlike the XFCE desktop, there is no desktop environment session wrapping Qtile. tuigreet launches Qtile directly as a Wayland compositor. On first startup, `wayland-autostart.sh` runs to initialize all supporting daemons:

1. **D-Bus** environment is updated for `WAYLAND_DISPLAY` and `XDG_CURRENT_DESKTOP`
2. **kanshi** starts for automatic multi-monitor profile switching
3. **polkit-gnome** agent starts for privilege escalation prompts
4. **dunst** starts as the notification daemon
5. **cliphist** begins watching the Wayland clipboard (text and images)
6. **Variety** starts for wallpaper management

Screen locking is handled by **gtklock**, triggered manually via `Super + Escape` or automatically before suspend/hibernate via a systemd `lock-before-sleep` service. There is no idle timeout -- locking is manual only.

Qtile's `config.py` also sets Wayland-specific environment variables:

```python
os.environ["XDG_SESSION_DESKTOP"] = "qtile:wlroots"
os.environ["XDG_CURRENT_DESKTOP"] = "qtile:wlroots"
```

And configures touchpad input (tap-to-click, natural scroll, disable-while-typing):

```python
wl_input_rules = {
    "type:touchpad": InputConfig(tap=True, natural_scroll=True, dwt=True),
}
```

### Declarative Configuration

| Component | Configured via | Source files |
|-----------|---------------|--------------|
| SDDM | `desktops/qtile.nix` | Nix module |
| Qtile | `home/configs/qtile/` (Python) | Symlinked to `~/.config/qtile` |
| Dunst | `home/configs/dunst/dunstrc` | Symlinked to `~/.config/dunst` |
| Kanshi | `home/configs/kanshi/config` | Symlinked to `~/.config/kanshi` |
| Rofi | `home/configs/rofi/` | Symlinked to `~/.config/rofi` |
| Swappy | `home/configs/swappy/config` | Symlinked to `~/.config/swappy` |
| gtklock | `home/configs/gtklock/` (config.ini, style.css) | Symlinked to `~/.config/gtklock` |
| wlogout | `home/configs/wlogout/` (layout, style, icons) | Symlinked to `~/.config/wlogout` |
| Polkit agent | systemd user service in `qtile.nix` | Nix module |
| Cursor theme | `home.pointerCursor` in `qtile.nix` | Nix module (Bibata-Modern-Classic, 24px) |

Everything is fully declarative through Nix and config files checked into this repo.

### Comparison with XFCE Desktop

| Concern | XFCE + Qtile (X11) | Qtile Wayland |
|---------|-------------------|---------------|
| Display server | X11 | Wayland (wlroots) |
| Display manager | LightDM | SDDM |
| Compositor | Picom (separate) | Built into Qtile |
| Clipboard | Greenclip | cliphist + wl-clipboard |
| Lock screen | xflock4 | gtklock |
| Power menu | XFCE session logout | wlogout |
| Screenshots | xfce4-screenshooter | grim + slurp + swappy |
| Notifications | XFCE notification daemon | dunst |
| Display management | N/A | kanshi (auto profiles) |
| Idle management | N/A | N/A (manual lock only) |
| Auth agent | XFCE session | polkit-gnome (systemd) |
| Session services | XFCE (keyring, Blueman, etc.) | gnome-keyring + standalone tools |

---

## Theming

The same wallust-based theming pipeline used in the XFCE desktop applies here:

1. **Variety** selects a wallpaper and saves it to `~/Pictures/current_wallpaper.jpg`
2. **wallust** generates `colors.json` from the wallpaper
3. **Qtile** reads `~/.cache/qtile/colors.json` to theme the bar, borders, and widgets
4. **Rofi** and **wlogout** also use wallust-generated colors from their respective cache dirs

### Cursor Theme

The cursor is set declaratively to **Bibata-Modern-Classic** at 24px, configured through both GTK and X11 (for XWayland) cursor settings.

---

## Display Management (Kanshi)

Kanshi automatically switches display profiles when monitors are connected or disconnected.

| Profile | Configuration |
|---------|--------------|
| **docked** | Laptop display off; HDMI-A-1 at 1280x720 (rotated 90); DP-7 at 1920x1080; DP-6 at 1920x1080 |
| **undocked** | Laptop display (eDP-1) at 1920x1080 |

To find output names and available modes, run `wlr-randr`. After editing `home/configs/kanshi/config`, reload with `kanshictl reload`.

For manual display arrangement, use `wdisplays` (a graphical tool included in the package list).

---

## Notifications (Dunst)

Dunst provides desktop notifications on Wayland.

| Setting | Value |
|---------|-------|
| Position | Top center, 35px offset below bar |
| Width | 300px |
| Corner radius | 10px |
| Font | FiraCode Nerd Font 11 |
| Frame | 3px white border |
| Follow | Keyboard focus |
| Timeout | 6 seconds (all urgencies) |
| Background | Semi-transparent black (`#00000070`) |
| Critical bg | Semi-transparent red (`#90000070`) |

Mouse actions on notifications: left-click closes, middle-click triggers action, right-click closes all.

---

## Lock Screen (gtklock)

gtklock provides the lock screen, triggered manually by `Super + Escape` or automatically before suspend/hibernate via a systemd service. There is no idle timeout.

- **Background:** Current wallpaper (`~/Pictures/current_wallpaper.jpg`)
- **Clock:** Large time display (96px FiraCode Nerd Font)
- **Behavior:** Input prompt hidden after 15 seconds of inactivity, reappears on keypress
- **Styling:** Custom GTK CSS (`home/configs/gtklock/style.css`)

PAM is configured for gtklock in the Nix module (`security.pam.services.gtklock = {};`) so it can actually authenticate and unlock.

A systemd `lock-before-sleep` service ensures the screen locks before suspend/hibernate, even when triggered from the command line.

---

## Power Menu (wlogout)

wlogout provides a graphical power menu triggered by `Ctrl + Alt + Delete` or by clicking the clock in the bar.

| Action | Keybind | Command |
|--------|---------|---------|
| Lock | `l` | `gtklock` |
| Hibernate | `h` | `gtklock -d && systemctl hibernate` |
| Exit (logout) | `e` | `qtile cmd-obj -o cmd -f shutdown` |
| Shutdown | `s` | `systemctl poweroff` |
| Suspend | `u` | `gtklock -d && systemctl suspend` |
| Reboot | `r` | `systemctl reboot` |

Each action includes a 1-second delay and has a custom icon in `home/configs/wlogout/icons/`.

---

## Screenshots & Screen Recording

### Screenshots (grim + slurp + swappy)

The screenshot workflow is launched via `Super + Print` or the camera icon in the bar. A Rofi menu offers two modes:

| Mode | How it works |
|------|-------------|
| **Selected area** | `slurp` to select a region, `grim` captures it, opens in `swappy` for annotation |
| **Fullscreen (3 sec delay)** | Waits 3 seconds, then `grim` captures the full screen into `swappy` |

Swappy saves screenshots to `~/Pictures/screenshots/` with the format `screenshot-YYYYMMDD-HHMMSS.png`.

### GIF Recording (wf-recorder + ffmpeg)

Triggered by a second press of `Super + Print` (the script toggles recording on/off):

1. `slurp` to select a screen region
2. `wf-recorder` captures video (max 10 minutes)
3. Press the shortcut again to stop recording
4. A Zenity file dialog prompts for a save location
5. `ffmpeg` converts the capture to an optimized GIF using a generated palette

---

## Clipboard (cliphist)

The Wayland clipboard is managed by `cliphist`, which watches both text and image copies via `wl-paste`. Access it with `Super + v`, which opens a Rofi menu with three modes:

| Invocation | Action |
|-----------|--------|
| `Super + v` | Browse clipboard history, paste selected item |
| Script arg `d` | Browse and delete a single entry |
| Script arg `w` | Wipe entire clipboard history (with confirmation) |

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
| `Super + v` | Open clipboard history (cliphist via Rofi) |
| `Super + Escape` | Lock screen (gtklock) |
| `Ctrl + Alt + Delete` | Open power menu (wlogout) |
| `Super + Print` | Screenshot / GIF recorder |

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
| `Super + Shift + r` | Reload Qtile config (hot reload, no restart) |

### Mouse Bindings

| Binding | Action |
|---------|--------|
| `Super + Left Click Drag` | Move floating window |
| `Super + Right Click Drag` | Resize floating window |
| `Super + Middle Click` | Bring window to front |

---

## Status Bar

The Qtile bar sits at the top of each screen (30px tall, 90% opacity, semi-transparent black background). Widgets are organized into colored pill-shaped groups using `RectDecoration`.

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
| Clock | Date + time (click opens wlogout) | Dark (`color11`) |

---

## Installed Packages

These packages are installed specifically by the Qtile Wayland desktop module:

| Package | Purpose |
|---------|---------|
| **Audio** | |
| `pavucontrol` | PulseAudio volume control GUI |
| `playerctl` | Media player control (MPRIS) |
| **Portals** | |
| `xdg-desktop-portal` | Desktop integration portal |
| `xdg-desktop-portal-wlr` | wlroots screen sharing portal |
| `xdg-desktop-portal-gtk` | GTK file picker portal |
| **File Manager** | |
| `thunar` | XFCE file manager |
| `tumbler` | Thumbnail service for Thunar |
| `ffmpegthumbnailer` | Video thumbnail generator |
| **Wayland Utilities** | |
| `rofi` | Application launcher |
| `grim` | Screenshot capture |
| `slurp` | Region selection |
| `swappy` | Screenshot annotation editor |
| `wf-recorder` | Screen recording |
| `wl-clipboard` | Wayland clipboard utilities |
| `cliphist` | Clipboard history manager |
| `gtklock` | GTK3-based lock screen |
| `polkit_gnome` | Authentication agent |
| `wlogout` | Power/logout menu |
| `ffmpeg` | Video processing (GIF conversion) |
| `wlr-randr` | Display output management CLI |
| `dunst` | Notification daemon |
| `brightnessctl` | Screen brightness control |
| `xwayland` | X11 compatibility layer |
| `nwg-look` | GTK theme settings editor |
| `wdisplays` | Graphical display arrangement tool |
| `kanshi` | Automatic display profile switching |
| `libnotify` | `notify-send` command for scripts |
| `python3` | Required for Qtile and update widget |

### Session Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `NIXOS_OZONE_WL` | `1` | Forces Electron apps to use Wayland |
| `QT_QPA_PLATFORMTHEME` | `qt5ct` | Qt theme configuration tool |

---

## Persistence

The following paths survive reboots via the impermanence module:

| Path | Purpose |
|------|---------|
| `~/.local/share/qtile` | Qtile state data |
| `~/.cache/qtile` | wallust-generated theme (colors.json) |
| `~/.cache/rofi` | wallust-generated Rofi theme |
| `~/.cache/wlogout` | wallust-generated wlogout theme |
| `~/.cache/thumbnails` | Thunar file thumbnails |

---

## Customization Tips

- **Change wallpaper source:** Configure Variety through its selector (`Ctrl + Alt + w`)
- **Edit keybindings:** Modify `home/configs/qtile/modules/keys.py`
- **Add/remove workspaces:** Edit `home/configs/qtile/modules/groups.py`
- **Change layouts:** Edit `home/configs/qtile/modules/layouts.py`
- **Modify bar widgets:** Edit `home/configs/qtile/modules/widgets.py`
- **Adjust display profiles:** Edit `home/configs/kanshi/config`, reload with `kanshictl reload`
- **Change lock screen appearance:** Edit `home/configs/gtklock/style.css` and `home/configs/gtklock/config.ini`
- **Customize notifications:** Edit `home/configs/dunst/dunstrc`
- **Edit power menu actions:** Edit `home/configs/wlogout/layout`
- **Configure GTK theme:** Run `nwg-look`
- **Switch to this desktop:** In `hosts/default.nix`, set `desktops.qtile` in your host's config list and rebuild
