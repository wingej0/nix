#!/usr/bin/env bash

dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &

# Polkit agent and swayidle - start via systemd user services
systemctl --user start polkit-gnome-authentication-agent-1 &
systemctl --user start swayidle &
dunst &
system76-power daemon &
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
# cp ~/.dotfiles/home/configs/qtile/scripts/variety-wayland.sh ~/.config/variety/scripts/set_wallpaper &
variety
