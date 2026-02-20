#!/usr/bin/env bash

dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY

# Display management
kanshi &

# Polkit agent
systemctl --user start polkit-gnome-authentication-agent-1 &
system76-power daemon &
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
# cp ~/.dotfiles/home/configs/qtile/scripts/variety-wayland.sh ~/.config/variety/scripts/set_wallpaper &
variety
