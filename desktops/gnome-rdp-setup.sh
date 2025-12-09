#!/usr/bin/env bash
# Helper script to configure GNOME Remote Desktop
# Due to a bug in GNOME 47, the Settings GUI doesn't show Remote Desktop
# Use this script to set the password via grdctl instead

set -e

echo "=== GNOME Remote Desktop Setup ==="
echo

# Stop service if running to ensure clean setup
if systemctl --user is-active --quiet gnome-remote-desktop.service; then
    echo "Stopping gnome-remote-desktop service for clean setup..."
    systemctl --user stop gnome-remote-desktop.service
    sleep 1
fi

# Clean up old certificates and credentials
CERT_DIR="${HOME}/.local/share/gnome-remote-desktop"
echo "Cleaning up old certificates..."
rm -rf "$CERT_DIR"
mkdir -p "$CERT_DIR"

echo "Starting gnome-remote-desktop service..."
systemctl --user start gnome-remote-desktop.service
sleep 3

# Disable RDP first to clear any bad state
echo "Resetting RDP configuration..."
grdctl rdp disable 2>/dev/null || true
sleep 1

echo
echo "Setting RDP password..."
echo "Enter your desired RDP password:"
if ! grdctl rdp set-credentials "${USER}"; then
    echo "Failed to set credentials. Trying alternative method..."
    # Try using dconf directly
    read -s -p "Password: " PASSWORD
    echo
    echo "$PASSWORD" | grdctl rdp set-credentials "${USER}"
fi

echo
echo "Configuring TLS..."
# Set TLS certificate and key paths via dconf
CERT_FILE="${CERT_DIR}/rdp-tls.crt"
KEY_FILE="${CERT_DIR}/rdp-tls.key"

# Generate self-signed certificate
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$(hostname)" \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE" 2>/dev/null

chmod 600 "$KEY_FILE"
chmod 644 "$CERT_FILE"

# Set certificate paths in dconf
dconf write /org/gnome/desktop/remote-desktop/rdp/tls-cert "'$CERT_FILE'"
dconf write /org/gnome/desktop/remote-desktop/rdp/tls-key "'$KEY_FILE'"

echo "✓ TLS configured"

echo
echo "Enabling RDP..."
grdctl rdp enable

echo
echo "Restarting service with new configuration..."
systemctl --user restart gnome-remote-desktop.service
sleep 3

echo
echo "✓ Setup complete!"
echo
echo "You can now connect to this machine using RDP:"
echo "  Address: $(hostname -I | awk '{print $1}'):3389"
echo "  Username: ${USER}"
echo "  Password: (the one you just set)"
echo
echo "Note: In Remmina, make sure to:"
echo "  - Set Security to 'Negotiate' or 'RDP'"
echo "  - Enable 'Ignore certificate'"
echo
echo "Status check:"
grdctl status --show-credentials
