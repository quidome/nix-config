{ config, ... }:
{
  networking.hostId = "4c6e5192";
  boot.supportedFilesystems = [ "zfs" ];
  boot.loader.grub.devices = [ "/dev/disk/by-id/ata-SAMSUNG_SSD_PM851_2.5_7mm_128GB_S1CTNSAG290123-part3" ];
  boot.loader.grub.copyKernels = true;
  boot.kernelParams = [
    "nohibernate"
    "ip=172.16.40.73::172.16.40.1:255.255.255.0:gaming-rig-rgb:enp42s0"
  ];
  boot = {
    initrd.availableKernelModules = [ "r8169" ];
    initrd.network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;

        # check https://search.nixos.org/options?channel=20.09&from=0&size=30&sort=relevance&query=boot.initrd.network.ssh.hostKeys
        # on how to generate hostkeys
        hostKeys = [
          "/etc/secrets/initrd/ssh_host_rsa_key"
          "/etc/secrets/initrd/ssh_host_ed25519_key"
        ];
      };
      postCommands = ''
        echo "zfs load-key -a; killall zfs" >> /root/.profile
      '';
    };
  };

  # zfs settings for maintenance
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;
  services.zfs.trim.enable = true;
}
