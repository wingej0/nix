#!/usr/bin/env bash

# NixOS Host Configuration Install Script
# Creates new host configurations for fresh NixOS installations from live USB
#
# Usage: ./install-host.sh [--dry-run|-n]

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$SCRIPT_DIR"
DRY_RUN=0
PASSWORD_HASH_FILE=""  # Set by collect_user_details if user needs to be added
USER_NEEDS_ADDING=false  # Track if user entry needs to be manually added
USER_FULL_NAME=""
USER_HASH_FILE=""
USER_GROUPS=()

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_section() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $*${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

die() {
    log_error "$*"
    exit 1
}

# ============================================================================
# CLEANUP AND ERROR HANDLING
# ============================================================================

cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Script failed with exit code $exit_code"
        log_info "No changes were made to the system"
    fi
}
trap cleanup EXIT

# ============================================================================
# INPUT VALIDATION FUNCTIONS
# ============================================================================

validate_hostname() {
    local hostname="$1"

    if [[ -z "$hostname" ]]; then
        log_error "Hostname cannot be empty"
        return 1
    fi

    if [[ ${#hostname} -gt 63 ]]; then
        log_error "Hostname too long (max 63 characters)"
        return 1
    fi

    if [[ ! "$hostname" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
        log_error "Invalid hostname format"
        log_error "Must contain only lowercase letters, numbers, and hyphens"
        log_error "Cannot start or end with hyphen"
        return 1
    fi

    return 0
}

validate_username() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Username cannot be empty"
        return 1
    fi

    if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        log_error "Invalid username format"
        log_error "Must start with lowercase letter or underscore"
        log_error "Can contain lowercase letters, numbers, hyphens, underscores"
        return 1
    fi

    if [[ ${#username} -gt 32 ]]; then
        log_warn "Username longer than 32 characters may cause issues"
    fi

    return 0
}

check_hostname_conflict() {
    local hostname="$1"

    # Check if host directory exists
    if [[ -d "${DOTFILES_ROOT}/hosts/${hostname}" ]]; then
        log_error "Host directory already exists: ${DOTFILES_ROOT}/hosts/${hostname}"
        log_error "Choose a different hostname or remove the existing configuration"
        return 1
    fi

    # Check if hostname in hosts/default.nix
    if grep -q "^[[:space:]]*${hostname}[[:space:]]*=" "${DOTFILES_ROOT}/hosts/default.nix" 2>/dev/null; then
        log_error "Hostname '${hostname}' already exists in hosts/default.nix"
        return 1
    fi

    # Check if hostname in flake.nix
    if grep -q "^[[:space:]]*${hostname}[[:space:]]*=" "${DOTFILES_ROOT}/flake.nix" 2>/dev/null; then
        log_error "Hostname '${hostname}' already exists in flake.nix"
        return 1
    fi

    return 0
}

check_user_in_config() {
    local username="$1"
    local users_nix="${DOTFILES_ROOT}/modules/users.nix"

    if [[ ! -f "$users_nix" ]]; then
        log_error "Cannot find users.nix at $users_nix"
        return 1
    fi

    # Check if username exists in userConfigs
    if grep -A 100 "userConfigs = {" "$users_nix" | grep -q "^[[:space:]]*${username}[[:space:]]*="; then
        log_success "User '$username' already exists in users.nix"
        return 0
    else
        log_warn "User '$username' does not exist in users.nix"
        return 1
    fi
}

collect_user_details() {
    local username="$1"

    # Get user details
    USER_FULL_NAME=$(prompt_with_default "Enter full name for $username" "$username")

    # Get password hash file location
    USER_HASH_FILE=$(prompt_with_default "Password hash file path" "/persist/${username}_password_hash")

    # Ask about extra groups
    log_info "User groups (wheel is required for sudo access):"
    USER_GROUPS=("wheel")

    if prompt_yes_no "Add nordvpn group access?" "n"; then
        USER_GROUPS+=("nordvpn")
    fi

    if prompt_yes_no "Add libvirtd group access (for virtual machines)?" "n"; then
        USER_GROUPS+=("libvirtd")
    fi

    # Set password hash file for later use
    PASSWORD_HASH_FILE="$USER_HASH_FILE"

    return 0
}

generate_users_nix_entry() {
    local username="$1"
    local full_name="$2"
    local hash_file="$3"
    shift 3
    local groups=("$@")

    # Format groups array for Nix
    local groups_str="[ "
    for group in "${groups[@]}"; do
        groups_str+="\"${group}\" "
    done
    groups_str+="]"

    cat <<EOF
    ${username} = {
      description = "${full_name}";
      hashedPasswordFile = "${hash_file}";
      extraGroups = ${groups_str};
    };
EOF
}

# ============================================================================
# ENVIRONMENT DETECTION
# ============================================================================

check_live_usb_environment() {
    local errors=0

    log_section "Checking Installation Environment"

    # Check if /mnt is mounted
    if ! mountpoint -q /mnt 2>/dev/null; then
        log_error "/mnt is not mounted"
        log_error "This script must be run during NixOS installation with drives mounted at /mnt"
        ((errors++))
    else
        log_success "/mnt is mounted"

        # Check if it's btrfs
        local fs_type
        fs_type=$(findmnt -n -o FSTYPE /mnt 2>/dev/null || echo "unknown")
        if [[ "$fs_type" != "btrfs" ]]; then
            log_error "/mnt is not a btrfs filesystem (found: ${fs_type})"
            log_error "This configuration requires btrfs with subvolumes"
            ((errors++))
        else
            log_success "/mnt is btrfs filesystem"
        fi
    fi

    # Check required subdirectories
    for dir in /mnt/persist /mnt/nix /mnt/boot; do
        if [[ ! -d "$dir" ]]; then
            log_error "$dir does not exist"
            log_error "Required directories: /mnt/persist /mnt/nix /mnt/boot"
            ((errors++))
        elif ! mountpoint -q "$dir" 2>/dev/null; then
            log_error "$dir exists but is not mounted"
            ((errors++))
        else
            log_success "$dir is mounted"
        fi
    done

    # Check swap
    if ! swapon --show 2>/dev/null | grep -q "^/dev"; then
        log_warn "No swap detected with 'swapon --show'"
        log_warn "Hibernation will not be available"
    else
        log_success "Swap is active"
    fi

    # Check required commands
    local missing_cmds=()
    for cmd in nixos-generate-config mkpasswd git blkid; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Required command not found: $cmd"
            missing_cmds+=("$cmd")
            ((errors++))
        fi
    done

    if [[ ${#missing_cmds[@]} -gt 0 ]]; then
        log_error "Missing commands: ${missing_cmds[*]}"
        log_info "You may need to enter a nix-shell with required packages"
    fi

    if [[ $errors -gt 0 ]]; then
        return 1
    fi

    log_success "Environment check passed"
    return 0
}

# ============================================================================
# INTERACTIVE PROMPTS
# ============================================================================

prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local result
    read -r -p "$(echo -e "${BLUE}${prompt}${NC} [${GREEN}${default}${NC}]: ")" result
    echo "${result:-$default}"
}

prompt_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local result

    if [[ "$default" == "y" ]]; then
        read -r -p "$(echo -e "${BLUE}${prompt}${NC} [${GREEN}Y${NC}/n]: ")" result
        result="${result:-y}"
    else
        read -r -p "$(echo -e "${BLUE}${prompt}${NC} [y/${GREEN}N${NC}]: ")" result
        result="${result:-n}"
    fi

    [[ "$result" =~ ^[Yy]$ ]]
}

prompt_selection() {
    local prompt="$1"
    shift
    local options=("$@")

    echo "" >&2
    echo -e "${BLUE}${prompt}${NC}" >&2
    for i in "${!options[@]}"; do
        echo "  $((i+1))) ${options[$i]}" >&2
    done
    echo "" >&2

    local selection
    while true; do
        read -r -p "$(echo -e "${BLUE}Select [1-${#options[@]}]:${NC} ")" selection
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#options[@]}" ]; then
            echo "${options[$((selection-1))]}"
            return 0
        fi
        log_error "Invalid selection. Please choose 1-${#options[@]}"
    done
}

gather_host_info() {
    log_section "Host Configuration"

    # Hostname
    while true; do
        HOSTNAME=$(prompt_with_default "Enter hostname" "nixos")
        if validate_hostname "$HOSTNAME" && check_hostname_conflict "$HOSTNAME"; then
            break
        fi
        echo ""
    done

    # Username
    while true; do
        USERNAME=$(prompt_with_default "Enter username" "wingej0")
        if validate_username "$USERNAME"; then
            break
        fi
        echo ""
    done

    # Check if user exists in users.nix
    echo ""
    if ! check_user_in_config "$USERNAME"; then
        echo ""
        log_warn "User '$USERNAME' will need to be added to modules/users.nix"
        if prompt_yes_no "Collect user details now?" "y"; then
            if ! collect_user_details "$USERNAME"; then
                die "Failed to collect user details"
            fi
            USER_NEEDS_ADDING=true
        else
            log_error "You must add the user to modules/users.nix before installation"
            log_error "The script will show you what to add at the end"
            USER_NEEDS_ADDING=true
        fi
    fi

    echo ""
    # Desktop environment
    DESKTOP=$(prompt_selection "Select desktop environment:" \
        "qtile" "gnome" "plasma" "cosmic" "xfce" "cinnamon")

    echo ""
    # Optional modules
    log_info "Optional modules (select which to include):"
    OPTIONAL_MODULES=()

    declare -A module_descriptions=(
        ["system76"]="System76 hardware drivers and power profiles"
        ["nordvpn"]="NordVPN service configuration"
        ["office"]="Office applications"
        ["flatpak"]="Flatpak service and app management"
        ["ai"]="AI tools (gemini-cli, claude-code)"
        ["mongodb"]="MongoDB database service"
        ["n8n"]="n8n workflow automation"
        ["immich"]="Immich photo management"
    )

    for module in system76 nordvpn office flatpak ai mongodb n8n immich; do
        echo -e "${CYAN}  - $module${NC}: ${module_descriptions[$module]}"
        if prompt_yes_no "    Include $module?" "n"; then
            OPTIONAL_MODULES+=("$module")
        fi
    done

    echo ""
    # System configuration
    TIMEZONE=$(prompt_with_default "Enter timezone" "America/Denver")
    LOCALE=$(prompt_with_default "Enter locale" "en_US.UTF-8")

    echo ""
    KERNEL=$(prompt_selection "Select kernel:" \
        "linuxPackages_zen" "linuxPackages" "linuxPackages_latest")

    echo ""
    STATE_VERSION=$(prompt_with_default "Enter NixOS state version" "25.11")

    echo ""
    if prompt_yes_no "Enable hibernation support?" "n"; then
        ENABLE_HIBERNATION="true"
    else
        ENABLE_HIBERNATION="false"
    fi
}

# ============================================================================
# HARDWARE CONFIGURATION VALIDATION
# ============================================================================

validate_btrfs_mounts() {
    local hw_config="$1"
    local errors=0

    log_section "Validating BTRFS Mount Configuration"

    # Check root mount - need to verify subvol=root, compress=zstd, and by-label
    if grep -q 'fileSystems."/" =' "$hw_config" && \
       grep -A 10 'fileSystems."/" =' "$hw_config" | grep -q 'device = "/dev/disk/by-label/nixos"' && \
       grep -A 10 'fileSystems."/" =' "$hw_config" | grep -q 'fsType = "btrfs"' && \
       grep -A 10 'fileSystems."/" =' "$hw_config" | grep -q '"subvol=root"' && \
       grep -A 10 'fileSystems."/" =' "$hw_config" | grep -q '"compress=zstd"'; then
        log_success "Root (/) mount configuration correct"
    else
        log_error "Root (/) mount missing or incorrect"
        log_error "  Required: device by-label/nixos, fsType btrfs, options [subvol=root compress=zstd]"
        ((errors++))
    fi

    # Check /persist mount with neededForBoot
    if grep -q 'fileSystems."/persist" =' "$hw_config" && \
       grep -A 10 'fileSystems."/persist" =' "$hw_config" | grep -q 'device = "/dev/disk/by-label/nixos"' && \
       grep -A 10 'fileSystems."/persist" =' "$hw_config" | grep -q 'neededForBoot = true' && \
       grep -A 10 'fileSystems."/persist" =' "$hw_config" | grep -q 'fsType = "btrfs"' && \
       grep -A 10 'fileSystems."/persist" =' "$hw_config" | grep -q '"subvol=persist"' && \
       grep -A 10 'fileSystems."/persist" =' "$hw_config" | grep -q '"compress=zstd"'; then
        log_success "/persist mount configuration correct (with neededForBoot)"
    else
        log_error "/persist mount missing, incorrect, or lacks neededForBoot = true"
        log_error "  Required: device by-label/nixos, neededForBoot = true, fsType btrfs,"
        log_error "           options [subvol=persist compress=zstd]"
        ((errors++))
    fi

    # Check /nix mount with noatime
    if grep -q 'fileSystems."/nix" =' "$hw_config" && \
       grep -A 10 'fileSystems."/nix" =' "$hw_config" | grep -q 'device = "/dev/disk/by-label/nixos"' && \
       grep -A 10 'fileSystems."/nix" =' "$hw_config" | grep -q 'fsType = "btrfs"' && \
       grep -A 10 'fileSystems."/nix" =' "$hw_config" | grep -q '"subvol=nix"' && \
       grep -A 10 'fileSystems."/nix" =' "$hw_config" | grep -q '"compress=zstd"' && \
       grep -A 10 'fileSystems."/nix" =' "$hw_config" | grep -q '"noatime"'; then
        log_success "/nix mount configuration correct (with noatime)"
    else
        log_error "/nix mount missing, incorrect, or lacks noatime"
        log_error "  Required: device by-label/nixos, fsType btrfs,"
        log_error "           options [subvol=nix compress=zstd noatime]"
        ((errors++))
    fi

    # Check boot mount
    if grep -q 'fileSystems."/boot" =' "$hw_config"; then
        if grep -A 5 'fileSystems."/boot" =' "$hw_config" | grep -q 'device = "/dev/disk/by-label/boot"'; then
            log_success "/boot mount using label (correct)"
        else
            log_warn "/boot mount may be using UUID instead of label"
            log_warn "  Recommended: device = \"/dev/disk/by-label/boot\""
        fi
    else
        log_warn "/boot mount not found in hardware-configuration.nix"
    fi

    # Check swap
    if grep -q 'swapDevices =' "$hw_config"; then
        if grep -A 5 'swapDevices =' "$hw_config" | grep -q 'device = "/dev/disk/by-label/swap"'; then
            log_success "Swap device using label (correct)"
        else
            log_warn "Swap device may be using UUID instead of label"
            log_warn "  Recommended: device = \"/dev/disk/by-label/swap\""
        fi
    else
        log_warn "Swap device not found in hardware-configuration.nix"
    fi

    if [[ $errors -gt 0 ]]; then
        log_error ""
        log_error "CRITICAL: hardware-configuration.nix has incorrect mount options"
        log_error "You must manually fix the mount configuration before installing"
        log_error "See README.md for the correct mount options"
        return 1
    fi

    log_success "All mount validations passed"
    return 0
}

# ============================================================================
# SWAP UUID DETECTION FOR HIBERNATION
# ============================================================================

detect_swap_uuid() {
    local hw_config="$1"

    # Extract swap device from hardware-configuration.nix
    local swap_device
    swap_device=$(grep -oP 'swapDevices\s*=\s*\[\s*\{\s*device\s*=\s*"\K[^"]+' "$hw_config" 2>/dev/null | head -1)

    if [[ -z "$swap_device" ]]; then
        log_error "Could not find swap device in $hw_config"
        return 1
    fi

    # Resolve to actual device if using label
    if [[ "$swap_device" =~ by-label ]]; then
        local real_device
        real_device=$(readlink -f "$swap_device" 2>/dev/null)
        if [[ -n "$real_device" ]]; then
            swap_device="$real_device"
        fi
    fi

    # Get UUID
    local swap_uuid
    swap_uuid=$(blkid -s UUID -o value "$swap_device" 2>/dev/null)

    if [[ -z "$swap_uuid" ]]; then
        log_error "Could not determine UUID for $swap_device"
        return 1
    fi

    echo "$swap_uuid"
}

# ============================================================================
# HARDWARE CONFIGURATION FIXING
# ============================================================================

fix_hardware_configuration() {
    local hw_config="$1"

    log_info "Automatically fixing hardware-configuration.nix..."

    # Create backup
    cp "$hw_config" "${hw_config}.bak"

    # Get the actual UUIDs/labels from the system
    local nixos_uuid=$(blkid -L nixos -s UUID -o value 2>/dev/null)
    local boot_uuid=$(blkid -L boot -s UUID -o value 2>/dev/null)
    local swap_uuid=$(blkid -L swap -s UUID -o value 2>/dev/null)

    if [[ -z "$nixos_uuid" ]] || [[ -z "$boot_uuid" ]]; then
        log_error "Could not detect disk labels. Make sure you used labels when formatting."
        return 1
    fi

    # Fix root filesystem
    if grep -q "fileSystems.\"/\"" "$hw_config"; then
        # Replace the entire root filesystem block
        sed -i '/fileSystems."\/"/,/};/{
            s|device = "/dev/disk/by-uuid/[^"]*"|device = "/dev/disk/by-label/nixos"|
            s|options = \[ [^]]*\]|options = [ "subvol=root" "compress=zstd" ]|
        }' "$hw_config"
        log_success "Fixed root (/) mount"
    fi

    # Fix persist filesystem - need to add neededForBoot
    if grep -q "fileSystems.\"/persist\"" "$hw_config"; then
        # Replace device and add neededForBoot
        sed -i '/fileSystems."\/persist"/,/};/{
            s|device = "/dev/disk/by-uuid/[^"]*"|device = "/dev/disk/by-label/nixos"|
            /device = .*nixos/a\    neededForBoot = true;
            s|options = \[ [^]]*\]|options = [ "subvol=persist" "compress=zstd" ]|
        }' "$hw_config"

        # Remove duplicate neededForBoot if any
        awk '!seen[$0]++ || !/neededForBoot/' "$hw_config" > "${hw_config}.tmp"
        mv "${hw_config}.tmp" "$hw_config"

        log_success "Fixed /persist mount (added neededForBoot)"
    fi

    # Fix nix filesystem
    if grep -q "fileSystems.\"/nix\"" "$hw_config"; then
        sed -i '/fileSystems."\/nix"/,/};/{
            s|device = "/dev/disk/by-uuid/[^"]*"|device = "/dev/disk/by-label/nixos"|
            s|options = \[ [^]]*\]|options = [ "subvol=nix" "compress=zstd" "noatime" ]|
        }' "$hw_config"
        log_success "Fixed /nix mount"
    fi

    # Fix boot filesystem
    if grep -q "fileSystems.\"/boot\"" "$hw_config"; then
        sed -i '/fileSystems."\/boot"/,/};/{
            s|device = "/dev/disk/by-uuid/[^"]*"|device = "/dev/disk/by-label/boot"|
        }' "$hw_config"
        log_success "Fixed /boot mount"
    fi

    # Fix swap
    if grep -q "swapDevices" "$hw_config"; then
        sed -i '/swapDevices/,/\];/{
            s|device = "/dev/disk/by-uuid/[^"]*"|device = "/dev/disk/by-label/swap"|
        }' "$hw_config"
        log_success "Fixed swap device"
    fi

    log_success "Hardware configuration automatically fixed!"
    log_info "Original saved as ${hw_config}.bak"

    return 0
}

# ============================================================================
# CONFIGURATION FILE GENERATION
# ============================================================================

generate_configuration_nix() {
    local hostname="$1"
    local kernel="$2"
    local timezone="$3"
    local locale="$4"
    local state_version="$5"
    local enable_hibernation="$6"
    local hw_config_path="$7"

    local hibernation_config=""
    if [[ "$enable_hibernation" == "true" ]]; then
        local swap_uuid
        if swap_uuid=$(detect_swap_uuid "$hw_config_path"); then
            hibernation_config="
  # Hibernation configuration
  boot.resumeDevice = \"/dev/disk/by-uuid/${swap_uuid}\";
  boot.kernelParams = [ \"resume=/dev/disk/by-uuid/${swap_uuid}\" ];
"
        else
            log_warn "Could not detect swap UUID for hibernation"
            hibernation_config="
  # Hibernation configuration
  # TODO: Add swap UUID manually
  # boot.resumeDevice = \"/dev/disk/by-uuid/<SWAP-UUID>\";
  # boot.kernelParams = [ \"resume=/dev/disk/by-uuid/<SWAP-UUID>\" ];
"
        fi
    fi

    cat <<EOF
# Configuration for ${hostname}
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
  boot.kernelPackages = pkgs.${kernel};
${hibernation_config}
  # Networking
  networking.hostName = "${hostname}";
  networking.networkmanager.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Time zone
  time.timeZone = "${timezone}";

  # Locale
  i18n.defaultLocale = "${locale}";

  # Keymap
  services.xserver.xkb.layout = "us";

  # Printing
  services.printing.enable = true;

  # Sound (PipeWire)
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable appimage support
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # State version
  system.stateVersion = "${state_version}";
}
EOF
}

generate_hosts_default_entry() {
    local hostname="$1"
    local desktop="$2"
    shift 2
    local optional_modules=("$@")

    local entry="    ${hostname} = [\n      ./${hostname}/configuration.nix\n\n      # Desktop environment\n"

    # Add all desktops, commenting out the ones not selected
    for de in gnome plasma cosmic xfce cinnamon qtile; do
        if [[ "$de" == "$desktop" ]]; then
            entry+="      desktops.${de}\n"
        else
            entry+="      # desktops.${de}\n"
        fi
    done

    # Add optional modules if any
    if [[ ${#optional_modules[@]} -gt 0 ]]; then
        entry+="\n      # Optional modules\n"
        for module in "${optional_modules[@]}"; do
            entry+="      ./../modules/${module}.nix\n"
        done
    fi

    entry+="    ];"

    echo -e "$entry"
}

generate_flake_entry() {
    local hostname="$1"
    local username="$2"

    cat <<EOF
      ${hostname} = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          username = "${username}";
          hostname = "${hostname}";
        };
        modules = [
          ./hosts
        ];
      };
EOF
}

# ============================================================================
# PASSWORD HASH CREATION
# ============================================================================

create_password_hash() {
    # Use custom hash file if set by add_user_to_config, otherwise default
    local hash_file
    if [[ -n "${PASSWORD_HASH_FILE:-}" ]]; then
        # PASSWORD_HASH_FILE is like "/persist/username_password_hash"
        # Need to prepend /mnt for live USB context
        hash_file="/mnt${PASSWORD_HASH_FILE}"
    else
        hash_file="/mnt/persist/password_hash"
    fi

    log_section "Password Hash Setup"

    if [[ $DRY_RUN -eq 1 ]]; then
        log_info "[DRY RUN] Would create password hash at $hash_file"
        return 0
    fi

    # Ensure persist directory exists
    if [[ ! -d "/mnt/persist" ]]; then
        log_error "/mnt/persist does not exist"
        return 1
    fi

    log_info "Creating password hash for user account"
    log_info "Hash will be saved to: $hash_file"
    log_warn "This password will be used for login after installation"

    # Prompt for password twice
    local password1=""
    local password2=""

    while true; do
        read -s -r -p "$(echo -e "${BLUE}Enter user password:${NC} ")" password1
        echo ""
        read -s -r -p "$(echo -e "${BLUE}Confirm password:${NC} ")" password2
        echo ""

        if [[ "$password1" == "$password2" ]]; then
            break
        else
            log_error "Passwords do not match. Try again."
        fi
    done

    if [[ -z "$password1" ]]; then
        log_error "Password cannot be empty"
        return 1
    fi

    # Generate hash
    local hash
    hash=$(mkpasswd -m sha-512 "$password1")

    # Clear password from memory
    unset password1 password2

    # Write to file with restricted permissions
    umask 077
    echo "$hash" > "$hash_file"
    chmod 600 "$hash_file"

    # Verify
    if [[ ! -f "$hash_file" ]] || [[ ! -s "$hash_file" ]]; then
        log_error "Failed to create password hash file"
        return 1
    fi

    log_success "Password hash created at $hash_file"
    return 0
}

# ============================================================================
# MAIN WORKFLOW FUNCTIONS
# ============================================================================

show_summary() {
    log_section "Configuration Summary"

    echo -e "${CYAN}Hostname:${NC} $HOSTNAME"
    echo -e "${CYAN}Username:${NC} $USERNAME"
    echo -e "${CYAN}Desktop:${NC} $DESKTOP"
    echo -e "${CYAN}Optional Modules:${NC} ${OPTIONAL_MODULES[*]:-none}"
    echo -e "${CYAN}Timezone:${NC} $TIMEZONE"
    echo -e "${CYAN}Locale:${NC} $LOCALE"
    echo -e "${CYAN}Kernel:${NC} $KERNEL"
    echo -e "${CYAN}State Version:${NC} $STATE_VERSION"
    echo -e "${CYAN}Hibernation:${NC} ${ENABLE_HIBERNATION}"

    if [[ $DRY_RUN -eq 1 ]]; then
        echo ""
        log_warn "DRY RUN MODE - No files will be created"
    fi

    echo ""
}

confirm_proceed() {
    if [[ $DRY_RUN -eq 1 ]]; then
        return 0
    fi

    prompt_yes_no "Proceed with host creation?" "y"
}

generate_host_configuration() {
    local host_dir="${DOTFILES_ROOT}/hosts/${HOSTNAME}"

    log_section "Generating Host Configuration"

    # Create host directory
    if [[ $DRY_RUN -eq 1 ]]; then
        log_info "[DRY RUN] Would create directory: $host_dir"
    else
        mkdir -p "$host_dir"
        log_success "Created host directory: $host_dir"
    fi

    # Generate hardware-configuration.nix
    log_info "Generating hardware-configuration.nix..."
    if [[ $DRY_RUN -eq 1 ]]; then
        log_info "[DRY RUN] Would run: nixos-generate-config --root /mnt --dir $host_dir"
    else
        if nixos-generate-config --root /mnt --dir "$host_dir"; then
            log_success "Generated hardware-configuration.nix"

            # Automatically fix the hardware configuration
            if ! fix_hardware_configuration "${host_dir}/hardware-configuration.nix"; then
                log_error "Failed to automatically fix hardware-configuration.nix"
                log_info "You may need to manually edit it"
                return 1
            fi

            # Validate
            if ! validate_btrfs_mounts "${host_dir}/hardware-configuration.nix"; then
                log_error "Hardware configuration validation failed after automatic fixes"
                log_info "Please check ${host_dir}/hardware-configuration.nix manually"
                return 1
            fi
        else
            log_error "Failed to generate hardware-configuration.nix"
            return 1
        fi
    fi

    # Generate configuration.nix
    log_info "Generating configuration.nix..."
    local config_content
    config_content=$(generate_configuration_nix \
        "$HOSTNAME" \
        "$KERNEL" \
        "$TIMEZONE" \
        "$LOCALE" \
        "$STATE_VERSION" \
        "$ENABLE_HIBERNATION" \
        "${host_dir}/hardware-configuration.nix")

    if [[ $DRY_RUN -eq 1 ]]; then
        log_info "[DRY RUN] Would create: ${host_dir}/configuration.nix"
        echo "Preview (first 20 lines):"
        echo "$config_content" | head -20
        echo "..."
    else
        echo "$config_content" > "${host_dir}/configuration.nix"
        log_success "Created configuration.nix"
    fi

    return 0
}

show_manual_steps() {
    log_section "Manual Configuration Steps Required"

    echo -e "${YELLOW}The following entries need to be manually added to your configuration:${NC}"
    echo ""

    # users.nix entry (if user needs to be added)
    if [[ "$USER_NEEDS_ADDING" == true ]]; then
        echo -e "${CYAN}═══ FILE: modules/users.nix ═══${NC}"
        echo -e "${YELLOW}Location:${NC} Inside 'userConfigs = {' attribute set, add:"
        echo ""
        if [[ -n "$USER_FULL_NAME" ]]; then
            generate_users_nix_entry "$USERNAME" "$USER_FULL_NAME" "$USER_HASH_FILE" "${USER_GROUPS[@]}"
        else
            # Provide a template if user didn't collect details
            generate_users_nix_entry "$USERNAME" "Full Name" "/persist/${USERNAME}_password_hash" "wheel"
        fi
        echo ""
    fi

    # hosts/default.nix entry
    echo -e "${CYAN}═══ FILE: hosts/default.nix ═══${NC}"
    echo -e "${YELLOW}Location:${NC} Inside 'hostConfigs = {' attribute set, add:"
    echo ""
    generate_hosts_default_entry "$HOSTNAME" "$DESKTOP" "${OPTIONAL_MODULES[@]}"
    echo ""

    echo -e "${CYAN}═══ FILE: flake.nix ═══${NC}"
    echo -e "${YELLOW}Location:${NC} Inside 'nixosConfigurations = {' attribute set, add:"
    echo ""
    generate_flake_entry "$HOSTNAME" "$USERNAME"
    echo ""

    echo -e "${CYAN}═══ Validation ═══${NC}"
    echo "After adding these entries, validate with:"
    echo "  1. nix flake check"
    echo "  2. nix eval .#nixosConfigurations.${HOSTNAME}.config.networking.hostName"
    echo ""
}

show_next_steps() {
    log_section "Next Steps"

    log_success "Host configuration files created successfully!"
    echo ""

    log_info "Follow these steps to complete the installation:"
    echo ""
    echo "1. Review generated files:"
    echo "   - ${DOTFILES_ROOT}/hosts/${HOSTNAME}/configuration.nix"
    echo "   - ${DOTFILES_ROOT}/hosts/${HOSTNAME}/hardware-configuration.nix"
    echo ""
    if [[ "$USER_NEEDS_ADDING" == true ]]; then
        echo "2. Manually add user entry to:"
        echo "   - ${DOTFILES_ROOT}/modules/users.nix"
        echo "   (See manual configuration steps above)"
        echo ""
        echo "3. Manually add host entries to:"
        echo "   - ${DOTFILES_ROOT}/hosts/default.nix"
        echo "   - ${DOTFILES_ROOT}/flake.nix"
        echo "   (See manual configuration steps above)"
        echo ""
        echo "4. Validate configuration:"
    else
        echo "2. Manually add host entries to:"
        echo "   - ${DOTFILES_ROOT}/hosts/default.nix"
        echo "   - ${DOTFILES_ROOT}/flake.nix"
        echo "   (See manual configuration steps above)"
        echo ""
        echo "3. Validate configuration:"
    fi
    echo "   cd ${DOTFILES_ROOT}"
    echo "   nix flake check"
    echo ""
    if [[ "$USER_NEEDS_ADDING" == true ]]; then
        echo "5. Install NixOS:"
        echo "   nixos-install --flake ${DOTFILES_ROOT}#${HOSTNAME}"
        echo ""
        echo "6. Set root password when prompted"
        echo "   (This will be lost after first boot due to impermanence)"
        echo ""
        echo "7. Reboot into your new system:"
        echo "   reboot"
    else
        echo "4. Install NixOS:"
        echo "   nixos-install --flake ${DOTFILES_ROOT}#${HOSTNAME}"
        echo ""
        echo "5. Set root password when prompted"
        echo "   (This will be lost after first boot due to impermanence)"
        echo ""
        echo "6. Reboot into your new system:"
        echo "   reboot"
    fi
    echo ""
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--dry-run)
                DRY_RUN=1
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  -n, --dry-run    Preview changes without creating files"
                echo "  -h, --help       Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    log_section "NixOS Host Configuration Installer"

    # Environment checks
    if ! check_live_usb_environment; then
        die "Environment check failed. Cannot proceed."
    fi

    # Gather information
    gather_host_info

    # Show summary and confirm
    show_summary
    if ! confirm_proceed; then
        log_info "Installation cancelled by user"
        exit 0
    fi

    # Generate host configuration
    if ! generate_host_configuration; then
        die "Failed to generate host configuration"
    fi

    # Create password hash
    if ! create_password_hash; then
        die "Failed to create password hash"
    fi

    # Show manual configuration steps
    show_manual_steps

    # Show next steps
    show_next_steps

    log_success "Installation script completed successfully!"
}

# Run main function
main "$@"
