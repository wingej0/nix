#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

MONGODB_PASSWORD_FILE="/persist/mongodb_password"
N8N_PASSWORD_FILE="/persist/n8n_mongodb_password"
HOSTNAME=$(hostname)

echo -e "${GREEN}n8n Setup Script${NC}"
echo "================================"
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Step 1: Verify MongoDB is running
echo -e "${YELLOW}[1/6]${NC} Verifying MongoDB is running..."
if ! systemctl is-active --quiet mongodb.service; then
    echo -e "  ${RED}✗${NC} MongoDB is not running!"
    echo "  Please run ./setup-mongodb.sh first"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} MongoDB is running"
echo

# Step 2: Check MongoDB root password
echo -e "${YELLOW}[2/6]${NC} Checking MongoDB root password..."
if [ ! -f "$MONGODB_PASSWORD_FILE" ]; then
    echo -e "  ${RED}✗${NC} MongoDB password file not found!"
    echo "  Please run ./setup-mongodb.sh first"
    exit 1
fi
MONGODB_ROOT_PASSWORD=$(cat "$MONGODB_PASSWORD_FILE")
echo -e "  ${GREEN}✓${NC} Root password file found"
echo

# Step 3: Handle n8n password file
echo -e "${YELLOW}[3/6]${NC} Checking n8n MongoDB password..."
if [ -f "$N8N_PASSWORD_FILE" ]; then
    echo -e "  ${GREEN}✓${NC} Password file exists at $N8N_PASSWORD_FILE"
    read -p "  Do you want to regenerate it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "  Keeping existing password"
        N8N_PASSWORD=$(cat "$N8N_PASSWORD_FILE")
        REGENERATE=false
    else
        # Generate new password
        N8N_PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 32)
        echo -n "$N8N_PASSWORD" > "$N8N_PASSWORD_FILE"
        chmod 600 "$N8N_PASSWORD_FILE"
        echo -e "  ${GREEN}✓${NC} New password generated and saved"
        REGENERATE=true
    fi
else
    echo "  Password file not found. Generating..."
    mkdir -p "$(dirname "$N8N_PASSWORD_FILE")"
    N8N_PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 32)
    echo -n "$N8N_PASSWORD" > "$N8N_PASSWORD_FILE"
    chmod 600 "$N8N_PASSWORD_FILE"
    echo -e "  ${GREEN}✓${NC} Password generated and saved to $N8N_PASSWORD_FILE"
    REGENERATE=true
fi
echo

# Step 4: Create/update n8n user in MongoDB
echo -e "${YELLOW}[4/6]${NC} Configuring n8n user in MongoDB..."

# Escape password for mongosh (handle special characters)
ESCAPED_ROOT_PASSWORD=$(printf '%s' "$MONGODB_ROOT_PASSWORD" | sed "s/'/\\\\'/g")
ESCAPED_N8N_PASSWORD=$(printf '%s' "$N8N_PASSWORD" | sed "s/'/\\\\'/g")

# Create or update the n8n user
mongosh admin --quiet --eval "
  db.auth('root', '$ESCAPED_ROOT_PASSWORD');

  // Try to drop existing user if regenerating
  try {
    db.getSiblingDB('n8n').dropUser('n8n');
  } catch (e) {
    // User might not exist yet, that's okay
  }

  // Create the n8n user
  db.getSiblingDB('n8n').createUser({
    user: 'n8n',
    pwd: '$ESCAPED_N8N_PASSWORD',
    roles: [
      { role: 'readWrite', db: 'n8n' },
      { role: 'dbAdmin', db: 'n8n' }
    ]
  });

  print('n8n user configured successfully');
" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} n8n database user configured"
else
    echo -e "  ${RED}✗${NC} Failed to configure n8n user"
    echo "  Check MongoDB logs for details"
    exit 1
fi
echo

# Step 5: Start n8n services
echo -e "${YELLOW}[5/6]${NC} Starting n8n services..."

# Stop services first
systemctl stop n8n.service 2>/dev/null || true
systemctl stop n8n-db-setup.service 2>/dev/null || true
systemctl stop nginx.service 2>/dev/null || true

# Start services in order
echo "  Starting n8n-ssl-setup..."
systemctl start n8n-ssl-setup.service
sleep 1

echo "  Starting n8n-db-setup..."
systemctl start n8n-db-setup.service
sleep 1

echo "  Starting nginx..."
systemctl start nginx.service
sleep 1

echo "  Starting n8n..."
systemctl start n8n.service
sleep 3

echo -e "  ${GREEN}✓${NC} Services started"
echo

# Step 6: Verify services are running
echo -e "${YELLOW}[6/6]${NC} Verifying services..."

MONGODB_OK=false
N8N_OK=false
NGINX_OK=false

if systemctl is-active --quiet mongodb.service; then
    echo -e "  ${GREEN}✓${NC} MongoDB: Running"
    MONGODB_OK=true
else
    echo -e "  ${RED}✗${NC} MongoDB: Failed"
fi

if systemctl is-active --quiet n8n.service; then
    echo -e "  ${GREEN}✓${NC} n8n: Running"
    N8N_OK=true
else
    echo -e "  ${RED}✗${NC} n8n: Failed"
fi

if systemctl is-active --quiet nginx.service; then
    echo -e "  ${GREEN}✓${NC} nginx: Running"
    NGINX_OK=true
else
    echo -e "  ${RED}✗${NC} nginx: Failed"
fi

echo

if [ "$MONGODB_OK" = true ] && [ "$N8N_OK" = true ] && [ "$NGINX_OK" = true ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ n8n setup complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "${BLUE}Access n8n at:${NC}"
    echo "  https://${HOSTNAME}.local:443"
    echo
    echo -e "${YELLOW}Note:${NC} You'll see a browser warning about the self-signed certificate."
    echo "      This is expected - click 'Advanced' and proceed anyway."
    echo
    exit 0
else
    echo -e "${RED}Some services failed to start.${NC}"
    echo
    echo "Check logs with:"
    echo "  journalctl -u mongodb -n 20"
    echo "  journalctl -u n8n -n 20"
    echo "  journalctl -u nginx -n 20"
    exit 1
fi
