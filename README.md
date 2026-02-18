# NixOS Configuration with Impermanence

This repository contains a modular NixOS configuration featuring "Erase Your Darlings" impermanence (Btrfs rollback on boot), dynamic desktop environment selection, and centralized system management.

## Project Architecture

This project follows a **DRY (Don't Repeat Yourself)** modular structure:

- **`modules/common-system.nix`**: Centralized home for shared system settings (Bootloader, Bluetooth, Sound, Printing, etc.).
- **`flake.nix`**: The entry point. It manages `stateVersion` as a `specialArg`, ensuring both the system and Home Manager are perfectly synchronized.
- **`hosts/`**: Contains machine-specific settings. Host configurations are **minimal**, only overriding what is unique to that hardware.
- **`desktops/`**: Plug-and-play desktop environments (GNOME, Plasma, Cosmic, Qtile, etc.).

---

## Automated Installation (Recommended)

### 1. Partition and Format Drives

Use cfdisk to create three partitions (swap can be any size):
- 512MB - EFI System Partition
- 64GB - Linux Swap
- Rest of Drive - Linux System

Run the following commands to partition and format the drives:

```bash
# Use your actual drive path instead of <drive>
mkfs.fat -F 32 -n boot <drive>
nix-shell -p btrfs-progs
mkfs.btrfs -L nixos <drive>
mkswap -L swap <drive>
swapon <drive>
mount /dev/disk/by-label/nixos /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/nix
umount /mnt
```

### 2. Mount Drives

Run the following commands to mount the drives using drive labels:

```bash
mount -o compress=zstd,subvol=root /dev/disk/by-label/nixos /mnt
mkdir /mnt/{persist,nix,boot}
mount -o compress=zstd,subvol=persist /dev/disk/by-label/nixos /mnt/persist
mount -o compress=zstd,noatime,subvol=nix /dev/disk/by-label/nixos /mnt/nix
mount /dev/disk/by-label/boot /mnt/boot
```

### 3. Clone Dotfiles Repository

```bash
nix-shell -p git
cd /mnt/persist
git clone https://github.com/wingej0/nix .dotfiles
cd .dotfiles
```

### 4. Run the Install Script

```bash
./install-host.sh
```

The script will:
- Validate your installation environment (btrfs mounts, required commands)
- Interactively prompt for:
  - Hostname
  - Username
  - Desktop environment (qtile, gnome, plasma, cosmic, xfce, cinnamon)
  - Optional modules (system76, nordvpn, office, flatpak, ai, mongodb, n8n, immich)
  - System settings (timezone, locale, kernel)
  - Hibernation support
- **Check if user exists** in `modules/users.nix`
  - If not found, automatically add the user by prompting for:
    - Full name
    - Password hash file location
    - Group memberships (wheel, nordvpn, libvirtd)
- Generate hardware-configuration.nix with `nixos-generate-config`
- **Automatically fix** hardware-configuration.nix with correct:
  - Disk labels instead of UUIDs
  - Btrfs mount options and subvolumes
  - `neededForBoot = true` for /persist
  - `noatime` for /nix
- Generate a **minimal** configuration.nix (shared settings are handled by `common-system.nix`)
- Create password hash in `/mnt/persist/password_hash` (or custom location for new users)
- Display the configuration snippets you need to add manually

### 5. Manual Configuration Steps

After the script completes, you need to manually add the generated entries to two files:

**Edit `hosts/default.nix`:**
```bash
vim hosts/default.nix
```
Add the host configuration block (associating the machine with its desktop and optional modules).

**Edit `flake.nix`:**
```bash
vim flake.nix
```
Add the `nixosSystem` block. Ensure you include the `stateVersion = "XX.XX";` in `specialArgs` as shown by the script.

### 6. Validate Configuration

```bash
nix flake check
nix eval .#nixosConfigurations.<hostname>.config.networking.hostName
```

### 7. Install NixOS

```bash
nixos-install --flake .#<hostname>
# Set root password when prompted (will be lost after first boot due to impermanence)
```

### 8. Reboot

```bash
reboot
```

Your user password will be the one you set during the script's password hash creation step.

---

## Manual Installation (Advanced)

If you prefer to set up the configuration manually or need to understand the process:

### 1-2. Partition, Format, and Mount Drives

Follow steps 1-2 from the automated installation above.

### 3. Generate Hardware Configuration

```bash
nixos-generate-config --root /mnt
vim /mnt/etc/nixos/hardware-configuration.nix
```

Add mount options to newly created partitions in the hardware-configuration and change mounts to labels:

```nix
fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" ];
    };

fileSystems."/persist" =
    { device = "/dev/disk/by-label/nixos";
        neededForBoot = true;  # This line is critical for impermanence!
        fsType = "btrfs";
        options = [ "subvol=persist" "compress=zstd" ];
    };

fileSystems."/nix" =
    { device = "/dev/disk/by-label/nixos";
        fsType = "btrfs";
        options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
        fsType = "vfat";
        options = [ "fmask=0022" "dmask=0022" ];
    };

swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];
```

### 4. Add User to Configuration

If your username doesn't exist in `modules/users.nix`, add it to the `userConfigs` attribute set:

```bash
vim modules/users.nix
```

Example user entry:
```nix
userConfigs = {
  youruser = {
    description = "Your Full Name";
    hashedPasswordFile = "/persist/youruser_password_hash";
    extraGroups = [ "wheel" "nordvpn" "libvirtd" ];
  };
  # ... other users
};
```

### 5. Create Password Hash

Create a password hash file matching the path in users.nix. Without this, your user credentials will be lost on reboot.

```bash
mkpasswd -m sha-512 <password> > /mnt/persist/youruser_password_hash
chmod 600 /mnt/persist/youruser_password_hash
```

### 6. Configure Basic System

Create a minimal `configuration.nix` for your new host. Shared settings are automatically imported via the host registry.

```bash
vim /mnt/etc/nixos/configuration.nix
```

Example minimal `configuration.nix`:
```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "your-hostname";
}
```

### 7. Install NixOS

```bash
nixos-install
# Set root password (will be lost after first boot due to impermanence)
```

### 8. Reboot

```bash
reboot
```

Your user password will be read from the password hash file you created in step 5.