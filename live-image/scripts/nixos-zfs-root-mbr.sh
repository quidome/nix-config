#!/usr/bin/env bash

# NixOS install with encrypted root and swap
# bios + mbr
#
# sda
# ├─sda1            BOOT (ext4)
# └─sda2            ENCRYPTED ZFS POOL
#
# zroot
# ├─local
# │ └─nix                  mounted to /nix
# ├─safe
# │ ├─root                 mounted to /
# │ ├─home                 mounted to /home
# │ └─var
# │   ├─lib
# │   │ └─AccountsService  gnome accounts service
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
    wipefs -a -t dos -f "$DISK"
    parted "$DISK" -- mklabel msdos
fi

pprint "Creating boot (ext4) partition"
parted "$DISK" -- mkpart primary 1 513
BOOT="$DISK-part1"

pprint "Creating Linux partition"
parted "$DISK" -- mkpart primary 513 100%
LINUX="$DISK-part2"

# Inform kernel
partprobe "$DISK"
sleep 1

pprint "Format BOOT partition $BOOT"
mkfs.ext4 -L boot "$BOOT"

ZFS=$LINUX

pprint "Create ZFS pool"
zpool create -o ashift=12 -o altroot="/mnt" -O mountpoint=none -O encryption=aes-256-gcm -O keyformat=passphrase zroot "$LINUX"

pprint "Create ZFS datasets"

zfs create -o mountpoint=none zroot/local
zfs create -o mountpoint=legacy zroot/local/nix

zfs create -o mountpoint=none zroot/safe
zfs create -o mountpoint=legacy zroot/safe/root
zfs create -o mountpoint=legacy zroot/safe/home

zfs create -o mountpoint=legacy zroot/safe/log
zfs create -o mountpoint=legacy -o xattr=sa -o acltype=posixacl zroot/safe/log/journal

# Mount the filesystems manually. The nixos installer will detect these mountpoints
# and save them to /mnt/nixos/hardware-configuration.nix during the install process.
mount -t zfs zroot/safe/root /mnt

# Creating swap zvol
read -p "Amount of G to use for swap: " -r
pprint "Creating $REPLY G swap zvol"

if [[ $REPLY ]] && [ $REPLY -gt 0 2>/dev/null ] ; then
 zfs create -V ${REPLY}G -b $(getconf PAGESIZE) \
            -o logbias=throughput -o sync=always\
            -o primarycache=metadata \
            -o com.sun:auto-snapshot=false zroot/swap

  sleep 2     # give zvol time to be created
  mkswap -f /dev/zvol/zroot/swap
  swapon /dev/zvol/zroot/swap
else
  pprint "Not creating swap, $REPLY is not a valid size"
fi

zfs snapshot zroot/safe/root@blank

pprint "Mount ZFS datasets"
mkdir /mnt/nix
mount -t zfs zroot/local/nix /mnt/nix

mkdir /mnt/home
mount -t zfs zroot/safe/home /mnt/home

mkdir -p /mnt/var/log
mount -t zfs zroot/safe/log /mnt/var/log

mkdir /mnt/var/log/journal
mount -t zfs zroot/safe/log/journal /mnt/var/log/journal

mkdir /mnt/boot
mount "$BOOT" /mnt/boot

pprint "Generate NixOS configuration"
nixos-generate-config --root /mnt

# Add LUKS and ZFS configuration
HOSTID=$(head -c8 /etc/machine-id)
LINUX_DISK_UUID=$(blkid --match-tag UUID --output value "$LINUX")

HARDWARE_CONFIG=$(mktemp)
cat <<CONFIG > "$HARDWARE_CONFIG"
{ config, ... }:
{
  networking.hostId = "$HOSTID";
  boot.supportedFilesystems = [ "zfs" ];
  boot.loader.grub.devices = [ "$DISK" ];
}
CONFIG

pprint "Generating config"
nixos-generate-config --root /mnt

pprint "Writing configuration to zfs-configuration.nix"
cat "$HARDWARE_CONFIG" > /mnt/etc/nixos/zfs-configuration.nix

pprint "Don't forget to include ./zfs-configuration in /etc/nixos/configuration.nix"
pprint "Continue on the configuration before running nixos-install --root /mnt"
