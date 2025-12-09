#!/usr/bin/env bash

# Script to generate TLS certificates for GNOME Remote Desktop (RDP)

set -e

CERT_DIR="$HOME/.local/share/gnome-remote-desktop/certificates"
CERT_FILE="$CERT_DIR/rdp-tls.crt"
KEY_FILE="$CERT_DIR/rdp-tls.key"

echo "GNOME Remote Desktop Certificate Generator"
echo "=========================================="
echo ""

# Create certificates directory if it doesn't exist
if [ ! -d "$CERT_DIR" ]; then
    echo "Creating certificates directory: $CERT_DIR"
    mkdir -p "$CERT_DIR"
else
    echo "Certificates directory already exists: $CERT_DIR"
fi

# Check if certificates already exist
if [ -f "$CERT_FILE" ] && [ -f "$KEY_FILE" ]; then
    echo ""
    echo "Certificates already exist:"
    echo "  - $CERT_FILE"
    echo "  - $KEY_FILE"
    echo ""
    read -p "Do you want to regenerate them? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing certificates."
        exit 0
    fi
    echo "Regenerating certificates..."
fi

# Get hostname for certificate CN
HOSTNAME=$(hostname)

# Generate self-signed certificate
echo ""
echo "Generating self-signed TLS certificate..."
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE" \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$HOSTNAME" \
    2>/dev/null

# Set appropriate permissions
chmod 600 "$KEY_FILE"
chmod 644 "$CERT_FILE"

echo ""
echo "✓ Certificates generated successfully!"
echo ""
echo "Certificate: $CERT_FILE"
echo "Private Key: $KEY_FILE"
echo ""
echo "Valid for: 3650 days (10 years)"
echo "Common Name: $HOSTNAME"
echo ""
echo "You can now enable Remote Desktop in GNOME Settings."
echo "The RDP service should automatically use these certificates."
