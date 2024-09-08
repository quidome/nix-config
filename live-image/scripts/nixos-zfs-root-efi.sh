#!/usr/bin/env bash

# NixOS install with encrypted root and swap
# uefi + gpt
#
# disk
# ├─disk_p3            BOOT (ext4)
# └─disk_p1            ENCRYPTED ZFS POOL
#
# zroot
# ├─local
# │ └─nix                  mounted to /nix
# ├─safe
# │ ├─root                 mounted to /
# │ ├─home                 mounted to /home
# │ └─var
# │   ├─lib
# │   │ ├─AccountsService  gnome accounts service
# │   │ └─docker           disable snapshots, docker utilized zfs
# │   └─log                mounted to /var/log
# │     └─journal          mounted to /var/log/journal (posixacl)
# └─swap                   swap zvol (be aware of the risks)

set -e

pprint () {
    local cyan="\e[96m"
    local default="\e[39m"
    # ISO8601 timestamp + ms
    local timestamp
    timestamp=$(date +%FT%T.%3NZ)
    echo -e "${cyan}${timestamp} $1${default}" 1>&2
}

# Set DISK
select ENTRY in $(ls /dev/disk/by-id/);
do
    DISK="/dev/disk/by-id/$ENTRY"
    echo "Installing system on $ENTRY."
    break
done

read -p "> Do you want to wipe all data on $ENTRY ?" -n 1 -r
echo # move to a new line
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
    # Clear disk
    wipefs -af "$DISK"
    sgdisk -Zo "$DISK"
fi

pprint "Creating boot (EFI) partition (numbered 3rd)"
sgdisk -n3:1M:+512M -t3:EF00 "$DISK"
BOOT="$DISK-part3"

pprint "Use remaining disk space for linux partition (numbered 1st)"
sgdisk -n1:0:0 -t1:BF01 "$DISK"
LINUX="$DISK-part1"

# Inform kernel
partprobe "$DISK"
sleep 1

pprint "Format BOOT partition $BOOT"
mkfs.vfat "$BOOT"

pprint "Create ZFS pool"
zpool create -o ashift=12 -o altroot="/mnt" -O mountpoint=none -O encryption=aes-256-gcm -O keyformat=passphrase zroot "$LINUX"

pprint "Create ZFS datasets"
zfs create -o mountpoint=none zroot/local
zfs create -o mountpoint=none zroot/safe
zfs create -o mountpoint=none zroot/safe/var
zfs create -o mountpoint=none zroot/safe/var/lib

# separate nix from the os
zfs create -o mountpoint=legacy zroot/local/nix

# setup base datasets
zfs create -o mountpoint=legacy zroot/safe/root
zfs create -o mountpoint=legacy zroot/safe/home

# setup posix acl dataset for journalctl
zfs create -o mountpoint=legacy zroot/safe/var/log
zfs create -o mountpoint=legacy -o xattr=sa -o acltype=posixacl zroot/safe/var/log/journal

# if using gnome:
zfs create -o mountpoint=legacy zroot/safe/var/lib/AccountsService

# If this system will use Docker (which manages its own datasets & snapshots):
zfs create -o mountpoint=legacy -o com.sun:auto-snapshot=false zroot/safe/var/lib/docker


# Mount the filesystems manually. The nixos installer will detect these mountpoints
# and save them to /mnt/nixos/hardware-configuration.nix during the install process.
pprint "Mount ZFS datasets"

mount -t zfs zroot/safe/root /mnt

mkdir /mnt/home
mount -t zfs zroot/safe/home /mnt/home

mkdir -p /mnt/var/log
mount -t zfs zroot/safe/var/log /mnt/var/log

mkdir -p /mnt/var/log/journal
mount -t zfs zroot/safe/var/log/journal /mnt/var/log/journal

mkdir -p /mnt/var/lib/AccountsService
mount -t zfs zroot/safe/var/lib/AccountsService /mnt/var/lib/AccountsService

mkdir -p /mnt/var/lib/docker
mount -t zfs zroot/safe/var/lib/docker /mnt/var/lib/docker

mkdir /mnt/nix
mount -t zfs zroot/local/nix /mnt/nix


pprint "Create initial snapshot"
zfs snapshot zroot/safe/root@blank


# setup boot partition
mkdir /mnt/boot
mount "$BOOT" /mnt/boot


# Creating swap zvol
read -p "Amount of G to use for swap: " -r
pprint "Creating $REPLY G swap zvol"

if [[ $REPLY ]] && [ "$REPLY" -gt 0 ] ; then
  zfs create -V "${REPLY}G" -b "$(getconf PAGESIZE)" \
             -o logbias=throughput -o sync=always\
             -o primarycache=metadata \
             -o com.sun:auto-snapshot=false zroot/swap

  sleep 2     # give zvol time to be created
  mkswap -f /dev/zvol/zroot/swap
  swapon /dev/zvol/zroot/swap
else
  pprint "Not creating swap, $REPLY is not a valid size"
fi


pprint "Generate NixOS configuration"
nixos-generate-config --root /mnt

# Add LUKS and ZFS configuration
HOSTID=$(head -c8 /etc/machine-id)

HARDWARE_CONFIG=$(mktemp)
cat <<CONFIG > "$HARDWARE_CONFIG"
{ config, ... }:
{
  networking.hostId = "$HOSTID";
  boot.supportedFilesystems = [ "zfs" ];
  boot.loader.grub.devices = [ "$BOOT" ];
  boot.loader.grub.copyKernels = true;
}
CONFIG

pprint "Writing configuration to zfs-configuration.nix"
cat "$HARDWARE_CONFIG" > /mnt/etc/nixos/zfs-configuration.nix

pprint "Don't forget to include ./zfs-configuration in /etc/nixos/configuration.nix"
pprint "Continue on the configuration before running nixos-install --root /mnt"
