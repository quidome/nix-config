{ config, ... }:
{
  networking.hostId = "16d91c92";
  boot.supportedFilesystems = [ "zfs" ];
  boot.loader.grub.devices = [ "/dev/disk/by-id/ata-RTNTE256PCA8EADL_sd0l82501r1sz71306zb-part3" ];
  boot.loader.grub.copyKernels = true;

  # zfs settings for maintenance
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;
  services.zfs.trim.enable = true;
}
