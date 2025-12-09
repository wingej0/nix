#!/usr/bin/env bash
# Helper script to configure GNOME Remote Desktop
# Due to a bug in GNOME 47, the Settings GUI doesn't show Remote Desktop
# Use this script to set the password via grdctl instead

set -e

echo "=== GNOME Remote Desktop Setup ==="
echo

# Check if service is running
if systemctl --user is-active --quiet gnome-remote-desktop.service; then
    echo "✓ gnome-remote-desktop service is running"
else
    echo "✗ gnome-remote-desktop service is not running"
    echo "  Try: systemctl --user start gnome-remote-desktop.service"
    exit 1
fi

echo
echo "Setting RDP password..."
echo "Enter your desired RDP password:"
grdctl rdp set-credentials "${USER}"

echo
echo "Enabling RDP..."
grdctl rdp enable

echo
echo "✓ Setup complete!"
echo
echo "You can now connect to this machine using RDP:"
echo "  Address: $(hostname).local:3389"
echo "  Username: ${USER}"
echo "  Password: (the one you just set)"
echo
echo "Status check:"
grdctl status --show-credentials
