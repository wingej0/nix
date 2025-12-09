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
    echo "  Starting service..."
    systemctl --user start gnome-remote-desktop.service
    sleep 2
fi

# Generate TLS certificates if they don't exist
CERT_DIR="${HOME}/.local/share/gnome-remote-desktop"
CERT_FILE="${CERT_DIR}/rdp-tls.crt"
KEY_FILE="${CERT_DIR}/rdp-tls.key"

if [[ ! -f "$CERT_FILE" ]] || [[ ! -f "$KEY_FILE" ]]; then
    echo
    echo "Generating TLS certificates..."
    mkdir -p "$CERT_DIR"

    # Generate self-signed certificate valid for 10 years
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=$(hostname)" \
        -keyout "$KEY_FILE" \
        -out "$CERT_FILE"

    chmod 600 "$KEY_FILE"
    chmod 644 "$CERT_FILE"

    echo "✓ Certificates generated"

    # Restart service to pick up new certificates
    echo "  Restarting service..."
    systemctl --user restart gnome-remote-desktop.service
    sleep 2
else
    echo "✓ TLS certificates already exist"
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
echo "  Address: $(hostname -I | awk '{print $1}'):3389"
echo "  Username: ${USER}"
echo "  Password: (the one you just set)"
echo
echo "Status check:"
grdctl status --show-credentials
