#!/usr/bin/env bash

# NixOS install with encrypted root and swap
# uefi + gpt
#
# disk
# ├─disk_p1            BOOT ()
# ├─disk_p3            BOOT (ext4)
# └─disk_p1            ENCRYPTED BCACHEFS
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
select ENTRY in $(lsblk -rn -o name);
do
    DISK="/dev/$ENTRY"
    echo "Installing system on $DISK."
    break
done

read -p "> Do you want to wipe all data on $DISK?" -n 1 -r
echo # move to a new line
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
    # Clear disk
    wipefs -af "$DISK"
    sgdisk -Zo "$DISK"
fi

pprint "Creating boot (EFI) partition (numbered 3rd)"
sgdisk -n3:1M:+512M -t3:EF00 "$DISK"
BOOT="${DISK}3"

# Creating swap zvol
read -p "Amount of G to use for swap: " -r
pprint "Creating $REPLY G swap zvol"

if [[ $REPLY ]] && [ "$REPLY" -gt 0 ] ; then
  pprint "Creating swap partition (numbered 2nd)"
  sgdisk -n2:0:+4G -t2:8200 "$DISK"
  SWAP="${DISK}2"

  sleep 2     # give zvol time to be created
  mkswap $SWAP
else
  pprint "Not creating swap, $REPLY is not a valid size"
fi

pprint "Use remaining disk space for linux partition (numbered 1st)"
sgdisk -n1:0:0 -t1:8300 "$DISK"
LINUX="${DISK}1"

# Inform kernel
partprobe "$DISK"
sleep 1

# Done partitioning
pprint "Setup ROOT partition $LINUX"
keyctl link @u @s
bcachefs format --encrypted $LINUX
bcachefs unlock $LINUX
mount $LINUX /mnt

pprint "Format BOOT partition $BOOT"
mkfs.vfat "$BOOT"
mkdir /mnt/boot
mount "$BOOT" /mnt/boot

pprint "Enable swap $SWAP"
swapon $SWAP

pprint "Generate NixOS configuration"
nixos-generate-config --root /mnt

cat <<EOF
Don't forget to add the following lines to configuration.nix:

  boot.supportedFilesystems = [ "bcachefs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

Edit /mnt/etc/nixos/configuration.nix to your likings and run:

  nixos-install

EOF
