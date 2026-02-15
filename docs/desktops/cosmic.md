# COSMIC (Wayland)

> **Module:** [`desktops/cosmic.nix`](../../desktops/cosmic.nix)
>
> This desktop option runs System76's COSMIC desktop environment on Wayland. COSMIC is still in active development, so most configuration is done **imperatively** through COSMIC's built-in Settings app. The Nix module enables the desktop, installs community extensions, and sets up persistence so imperative settings survive reboots.

## Screenshots

<!-- Replace the paths below with actual screenshots -->

![Desktop Overview](../images/cosmic/desktop-overview.png)
*COSMIC desktop with dock and tiled windows*

---

## Architecture

```
cosmic-greeter (Wayland) ─── login ───▶ COSMIC Shell
                                           ├── cosmic-comp          (Wayland compositor)
                                           ├── cosmic-panel         (top bar / dock)
                                           ├── cosmic-app-library   (application launcher)
                                           ├── cosmic-settings      (settings app)
                                           ├── system76-scheduler   (process priority scheduler)
                                           ├── cosmic-ext-tweaks    (community tweaks tool)
                                           └── cosmic-ext-bg-theme  (wallpaper-based theming)
```

### How It Fits Together

The COSMIC greeter handles login and launches the full COSMIC session. Unlike the GNOME and Qtile desktops in this repo, very little is configured declaratively -- COSMIC does not yet have a mature dconf-like interface for Nix-managed settings. Instead:

1. **Nix enables the desktop** and installs packages
2. **COSMIC Settings** is used after login to configure the desktop imperatively
3. **Persistence** ensures those imperative settings survive the impermanent root rollback

The `system76-scheduler` service is enabled to provide System76's process priority management, which optimizes responsiveness for the foreground application.

### Declarative vs Imperative Configuration

| What | How | Persists via |
|------|-----|-------------|
| Desktop enablement | Nix (`services.desktopManager.cosmic.enable`) | Nix config |
| Greeter | Nix (`services.displayManager.cosmic-greeter.enable`) | Nix config |
| Installed packages/extensions | Nix (`environment.systemPackages`) | Nix config |
| Background theme service | Nix (systemd user service) | Nix config |
| Cursor theme/size | Nix (environment variables) | Nix config |
| Desktop layout, keybindings, appearance, dock, etc. | **Imperative** (COSMIC Settings) | Impermanence (`~/.config/cosmic`) |

---

## Wallpaper-Based Theming (cosmic-ext-bg-theme)

The module imports [`modules/cosmic-bg.nix`](../../modules/cosmic-bg.nix), which runs **cosmic-ext-bg-theme** as a systemd user service. This community extension automatically generates a color theme from the current wallpaper, similar to how wallust works in the Qtile desktops.

The service starts with the graphical session and restarts on failure.

---

## Cursor Theme

The cursor is set via environment variables (for both Wayland and XWayland):

| Variable | Value |
|----------|-------|
| `XCURSOR_THEME` | Bibata-Modern-Classic |
| `XCURSOR_SIZE` | 24 |

---

## Installed Packages

These packages are installed specifically by the COSMIC desktop module:

| Package | Purpose |
|---------|---------|
| `cosmic-ext-tweaks` | Community tweaks/settings tool for COSMIC |
| `cosmic-applets-collection` | Community applet collection (from [ext-cosmic-applets-flake](https://github.com/wingej0/ext-cosmic-applets-flake)) |

The `cosmic-applets-collection` flake input also provides the `cosmic-ext-bg-theme` binary used by the background theming service.

### Session Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `COSMIC_DATA_CONTROL_ENABLED` | `1` | Enables clipboard data control protocol (required for clipboard managers) |

---

## Persistence

The following paths survive reboots via the impermanence module:

| Path | Purpose |
|------|---------|
| `~/.config/cosmic` | All COSMIC desktop settings (imperative configuration) |
| `~/.local/state/cosmic` | COSMIC runtime state |
| `~/.local/state/cosmic-comp` | Compositor state |
| `~/.config/cosmic-initial-setup-done` | Prevents first-run wizard on each boot |

These persistence entries are critical -- without them, all imperative COSMIC settings would be lost on every reboot.

---

## Customization Tips

- **All appearance/behavior settings:** Use COSMIC Settings (the built-in settings app) -- changes persist across reboots via the impermanence entries above
- **Install more applets/extensions:** Add to the `environment.systemPackages` list in `cosmic.nix`
- **Change cursor theme:** Edit the `XCURSOR_THEME` and `XCURSOR_SIZE` environment variables in `cosmic.nix`
- **Disable background theming:** Remove the `modules/cosmic-bg.nix` import from `cosmic.nix`
- **Switch to this desktop:** In `hosts/default.nix`, set `desktops.cosmic` in your host's config list and rebuild

---

## Note on Declarative Configuration

COSMIC is under active development and does not yet provide stable interfaces for declarative configuration management from Nix. As the desktop matures and tools for managing COSMIC settings declaratively become available, this module and documentation will be expanded to cover keybindings, theming, dock settings, and other preferences in a reproducible way.
