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
      # This will use udhcp to get an ip address.
      # Make sure you have added the kernel module for your network driver to `boot.initrd.availableKernelModules`, 
      # so your initrd can load it!
      # Static ip addresses might be configured using the ip argument in kernel command line:
      # https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
      enable = true;

      # ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>:
      #    <dns0-ip>:<dns1-ip>:<ntp0-ip>

      ssh = {
        enable = true;
        # To prevent ssh from freaking out because a different host key is used,
        # a different port for dropbear is useful (assuming the same host has also a normal sshd running)
        port = 2222;

        # check https://search.nixos.org/options?channel=20.09&from=0&size=30&sort=relevance&query=boot.initrd.network.ssh.hostKeys
        # on how to generate hostkeys
        hostKeys = [
          "/etc/secrets/initrd/ssh_host_rsa_key"
          "/etc/secrets/initrd/ssh_host_ed25519_key"
        ];

        # public ssh key used for login
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKKNAKrwchOKKqlFJjwCJu+0Uv0X+YvWExjQ+HghNA0 qmeijer@bol.com"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGaDOuD9ffRB6dYMc2bgO3LxjupiO2gQs8TM4gYdwyDS quidome@gmail.com"
        ];
      };
      # this will automatically load the zfs password prompt on login
      # and kill the other prompt so boot can continue
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
