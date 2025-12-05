# Qtile Wayland Configuration Improvements

## Issues & Recommendations for `desktops/qtile.nix`

### 1. XServer enabled but running Wayland (lines 3-4)
**Issue**: `services.xserver.enable = true` is X11-centric and adds unnecessary overhead for pure Wayland.

**Recommendation**: Keep it only if you need XWayland compatibility, otherwise it's not strictly required for Wayland-only setups.

---

### 2. Rofi not Wayland-native (line 46)
**Issue**: Using standard `rofi` instead of Wayland-native version.

**Fix**:
```nix
rofi-wayland  # Instead of rofi
```

---

### 3. Missing Wayland compositor essentials
**Recommendation**: Consider adding these useful Wayland tools:
```nix
environment.systemPackages = with pkgs; [
  # Status bars (alternatives to Qtile's built-in)
  waybar
  eww

  # Display configuration
  kanshi

  # Blue light filter
  wlsunset
  # or
  gammastep

  # Notifications (Wayland-native alternative to dunst)
  mako
];
```

---

### 4. XDG Portal configuration too vague (line 73)
**Issue**: `config.common.default = "*"` is imprecise for wlroots compositors.

**Fix**:
```nix
xdg.portal = {
  enable = true;
  wlr.enable = true;
  extraPortals = with pkgs; [
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];
  config = {
    common = {
      default = [ "wlr" "gtk" ];
    };
  };
};
```

---

### 5. SDDM Wayland session not enabled (line 6)
**Issue**: SDDM not configured for Wayland sessions.

**Fix**:
```nix
services.displayManager.sddm = {
  enable = true;
  wayland.enable = true;
};
```

---

### 6. QT Wayland platform not set (line 88)
**Issue**: Missing fallback for Qt applications on Wayland.

**Fix**:
```nix
environment.sessionVariables = {
  NIXOS_OZONE_WL = "1";
  QT_QPA_PLATFORM = "wayland;xcb";  # Add this
  QT_QPA_PLATFORMTHEME = "qt5ct";
};
```

---

### 7. Consider qt6ct for modern Qt apps (line 88)
**Recommendation**: If using Qt6 applications, add:
```nix
environment.systemPackages = with pkgs; [
  qt6ct
  # ...
];

environment.sessionVariables = {
  QT_QPA_PLATFORMTHEME = "qt6ct";  # Or keep qt5ct if you prefer
};
```

---

### 8. Idle/lock automation not configured
**Issue**: `swayidle` and `swaylock-effects` installed but no automation configured.

**Recommendation**: Add proper idle management:
```nix
# In home-manager configuration
services.swayidle = {
  enable = true;
  events = [
    { event = "before-sleep"; command = "${pkgs.swaylock-effects}/bin/swaylock"; }
  ];
  timeouts = [
    { timeout = 300; command = "${pkgs.swaylock-effects}/bin/swaylock"; }
    { timeout = 600; command = "${pkgs.systemd}/bin/systemctl suspend"; }
  ];
};
```

---

### 9. Polkit agent not auto-started (line 56)
**Issue**: `polkit_gnome` installed but not launched automatically.

**Fix Option 1** (systemd user service):
```nix
systemd.user.services.polkit-gnome-authentication-agent-1 = {
  description = "polkit-gnome-authentication-agent-1";
  wantedBy = [ "graphical-session.target" ];
  wants = [ "graphical-session.target" ];
  after = [ "graphical-session.target" ];
  serviceConfig = {
    Type = "simple";
    ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    Restart = "on-failure";
    RestartSec = 1;
    TimeoutStopSec = 10;
  };
};
```

**Fix Option 2** (Qtile autostart):
Add to your Qtile hooks:
```python
@hook.subscribe.startup_once
def autostart():
    subprocess.Popen(["/usr/bin/env", "polkit-gnome-authentication-agent-1"])
```

---

## Priority Order

1. **High Priority**: #2 (rofi-wayland), #4 (XDG portals), #5 (SDDM wayland), #9 (polkit)
2. **Medium Priority**: #6 (Qt platform), #8 (idle management)
3. **Low Priority**: #1 (xserver), #3 (additional tools), #7 (qt6ct)
