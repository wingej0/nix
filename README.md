# Multi-Host Nix Config with Impermanence

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
mount /dev/drive/by-label/nixos /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/nix
umount /mnt
```

### Mount Drives

