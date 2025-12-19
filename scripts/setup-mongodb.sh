#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSWORD_FILE="/persist/mongodb_password"

echo -e "${GREEN}MongoDB Setup Script${NC}"
echo "================================"
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Step 1: Stop any stale mongodb-for-setup service
echo -e "${YELLOW}[1/5]${NC} Checking for stale services..."
if systemctl is-active --quiet mongodb-for-setup.service; then
    echo "  Stopping stale mongodb-for-setup.service..."
    systemctl stop mongodb-for-setup.service
    echo -e "  ${GREEN}✓${NC} Stopped"
else
    echo -e "  ${GREEN}✓${NC} No stale services found"
fi
echo

# Step 2: Handle password file
echo -e "${YELLOW}[2/5]${NC} Checking MongoDB password file..."
if [ -f "$PASSWORD_FILE" ]; then
    echo -e "  ${GREEN}✓${NC} Password file exists at $PASSWORD_FILE"
    read -p "  Do you want to regenerate it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "  Keeping existing password"
    else
        # Generate new password
        NEW_PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 32)
        echo -n "$NEW_PASSWORD" > "$PASSWORD_FILE"
        chmod 600 "$PASSWORD_FILE"
        echo -e "  ${GREEN}✓${NC} New password generated and saved"
        echo "  Password: $NEW_PASSWORD"
        echo "  (Save this if you need manual access)"
    fi
else
    echo "  Password file not found. Generating..."
    mkdir -p "$(dirname "$PASSWORD_FILE")"
    NEW_PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 32)
    echo -n "$NEW_PASSWORD" > "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"
    echo -e "  ${GREEN}✓${NC} Password generated and saved to $PASSWORD_FILE"
    echo "  Password: $NEW_PASSWORD"
    echo "  (Save this if you need manual access)"
fi
echo

# Step 3: Stop MongoDB if running
echo -e "${YELLOW}[3/5]${NC} Stopping MongoDB service..."
if systemctl is-active --quiet mongodb.service; then
    systemctl stop mongodb.service
    echo -e "  ${GREEN}✓${NC} Stopped"
else
    echo -e "  ${GREEN}✓${NC} Already stopped"
fi
echo

# Step 4: Start MongoDB
echo -e "${YELLOW}[4/5]${NC} Starting MongoDB service..."
systemctl start mongodb.service
sleep 2
echo -e "  ${GREEN}✓${NC} Started"
echo

# Step 5: Verify MongoDB is running
echo -e "${YELLOW}[5/5]${NC} Verifying MongoDB status..."
if systemctl is-active --quiet mongodb.service; then
    echo -e "  ${GREEN}✓${NC} MongoDB is running!"
    echo
    systemctl status mongodb.service --no-pager -l | head -n 10
    echo
    echo -e "${GREEN}MongoDB setup complete!${NC}"
    exit 0
else
    echo -e "  ${RED}✗${NC} MongoDB failed to start"
    echo
    echo "Showing recent logs:"
    journalctl -u mongodb -n 20 --no-pager
    exit 1
fi
