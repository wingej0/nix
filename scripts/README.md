# Setup Scripts

This directory contains setup scripts for initializing services in the NixOS configuration.

## MongoDB Setup

**Script:** `setup-mongodb.sh`

Sets up MongoDB with authentication and generates/manages the root password.

**Usage:**
```bash
cd ~/.dotfiles/scripts
sudo ./setup-mongodb.sh
```

**What it does:**
1. Stops any stale MongoDB setup services
2. Generates a secure random password (or uses existing one)
3. Saves password to `/persist/mongodb_password`
4. Restarts MongoDB service
5. Verifies MongoDB is running

**Notes:**
- Must be run as root (use `sudo`)
- If password file exists, you'll be prompted to keep or regenerate
- New passwords are displayed once - save them if you need manual access
- Password file is automatically used by the NixOS configuration

## n8n Setup

**Script:** `setup-n8n.sh`

Sets up n8n workflow automation with MongoDB backend and HTTPS access.

**Usage:**
```bash
cd ~/.dotfiles/scripts
sudo ./setup-n8n.sh
```

**What it does:**
1. Verifies MongoDB is running
2. Generates a secure password for the n8n database user
3. Creates/updates the n8n user in MongoDB
4. Saves password to `/persist/n8n_mongodb_password`
5. Starts all required services (n8n, nginx, support services)
6. Verifies everything is running
7. Displays access URL

**Notes:**
- Must be run as root (use `sudo`)
- **Requires MongoDB to be set up first** - run `setup-mongodb.sh` before this
- If password file exists, you'll be prompted to keep or regenerate
- Regenerating will update the MongoDB user with the new password
- Access n8n at `https://<hostname>.local:443`
- Self-signed certificate will trigger browser warning (this is normal)

## Typical First-Time Setup

```bash
cd ~/.dotfiles/scripts

# Step 1: Set up MongoDB
sudo ./setup-mongodb.sh

# Step 2: Set up n8n
sudo ./setup-n8n.sh
```

## Troubleshooting

### MongoDB won't start
- Check logs: `journalctl -u mongodb -n 50`
- Verify password file exists: `ls -l /persist/mongodb_password`
- Check disk space: `df -h /var/db`

### n8n won't start
- Ensure MongoDB is running: `systemctl status mongodb`
- Check n8n logs: `journalctl -u n8n -n 50`
- Check nginx logs: `journalctl -u nginx -n 50`
- Verify password files exist:
  - `ls -l /persist/mongodb_password`
  - `ls -l /persist/n8n_mongodb_password`

### Can't access n8n web interface
- Check nginx status: `systemctl status nginx`
- Verify firewall allows port 443: `sudo firewall-cmd --list-ports` (if using firewalld)
- Check SSL certificate: `ls -l /persist/ssl/`
- Try: `curl -k https://localhost:443`

### Reset everything
If you need to start completely fresh:
```bash
# Stop services
sudo systemctl stop n8n nginx mongodb

# Remove password files
sudo rm /persist/mongodb_password
sudo rm /persist/n8n_mongodb_password

# Remove databases (WARNING: This deletes all data!)
sudo rm -rf /var/db/mongodb/*
sudo rm -rf /var/lib/n8n/*

# Re-run setup scripts
sudo ./setup-mongodb.sh
sudo ./setup-n8n.sh
```
