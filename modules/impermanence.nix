{ config, lib, pkgs, modulesPath, ... }:
{
  # Rollback root subvolume on boot, but skip if resuming from hibernation
  boot.initrd.postDeviceCommands = lib.mkBefore ''
    # Check if we're resuming from hibernation by looking for swap signature
    RESUME_DEVICE="${config.boot.resumeDevice}"
    RESUMING=0

    if [ -n "$RESUME_DEVICE" ] && [ -b "$RESUME_DEVICE" ]; then
      # Read swap signature to detect if hibernation image exists
      if $(dd if=$RESUME_DEVICE bs=1 count=4 skip=4086 2>/dev/null | grep -q "SWSP"); then
        RESUMING=1
        echo "Hibernation image detected, skipping root rollback"
      fi
    fi

    if [ $RESUMING -eq 0 ]; then
      mkdir -p /btrfs_tmp
      mount /dev/disk/by-label/nixos /btrfs_tmp
      if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    fi
  '';
}