# NixOS Configuration with Impermanence

## Installation with Impermanence

### Partition and Format Drives

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

### Mount Drives

Run the following commands to mount the drives using drive labels.

```bash
mount -o compress=zstd,subvol=root /dev/disk/by-label/nixos /mnt
mkdir /mnt/{persist,nix,boot}
mount -o compress=zstd,subvol=persist /dev/disk/by-label/nixos /mnt/persist
mount -o compress=zstd,noatime,subvol=nix /dev/disk/by-label/nixos /mnt/nix
mount /dev/disk/by-label/boot /mnt/boot
```

### Generate Config, Add Mount Options, and Install NixOS

```bash
nixos-generate-config --root /mnt
vim /mnt/etc/nixos/hardware-configuration.nix
```

Add mount options to newly created partitions in the hardware-configuration and change mounts to labels.  See example:

```nix
fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" ];
    };

fileSystems."/persist" =
    { device = "/dev/disk/by-label/nixos";
        neededForBoot = true;  # This line is important!
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

After adding the mount points, edit configuration.nix to enable a user, add a text editor, and install git.  See installation documentation if needed.

```bash
vim /mnt/etc/nixos/configuration.nix
```

Install NixOS.

```bash
nixos-install
# Set root password - However, this will go away with impermanence
# Set user password for initial login
nixos-enter --root /mnt -c 'passwd <username>'
```

Reboot

## Persist the User

Create a file in /persist called password_hash, and paste the output of this command in it.  Without this, as soon as you activate impermanence and reboot, your user credentials will be gone.

```bash
mkpasswd -m sha-512 my_password # Replace my_password with your actual login password.
```