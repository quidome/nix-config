{ lib, pkgs, ... }:
{
  imports = [
    ./shared.nix
    ./vars.nix
    ./hardware-configuration.nix
    ../../modules
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernel.sysctl = { "vm.swappiness" = 1; };
    kernelParams = [ "consoleblank=60" ];

    initrd.postDeviceCommands = lib.mkAfter ''
      mkdir /mnt
      mount -t btrfs /dev/mapper/enc /mnt
      btrfs subvolume delete /mnt/root
      btrfs subvolume snapshot /mnt/root-blank /mnt/root
    '';

    supportedFilesystems = [ "btrfs" ];
  };

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_IE.UTF-8";

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    cpu.intel.updateMicrocode = true;
  };

  networking = {
    hostName = "nimbus";
    firewall.enable = true;
    networkmanager.enable = true;

    wg-quick.interfaces.wg0 = {
      autostart = false;
      address = [ "172.16.41.14/32" ];
      dns = [ "172.16.41.1" "lan.balti.casa" "balti.casa" "quido.me" ];
      listenPort = 51820;
      privateKeyFile = "/etc/secrets/wg0-private";

      peers = [
        {
          publicKey = "YkOAj87heEGLFgM8h1VhsBfBp1qYgpcpTAz9NUOTTQU=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "wg.quido.me:51232";
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    home-manager
    calibre
    gimp

    # gaming
    discord
    factorio-demo
    freeciv
    openttd
    unciv
    wesnoth

    docker-compose
    lazydocker

    libimobiledevice
    ifuse
    virt-manager
    wireshark
  ];

  powerManagement.enable = true;

  programs.steam.enable = true;

  services = {
    btrfs.autoScrub.enable = true;
    btrfs.autoScrub.interval = "weekly";

    fprintd = {
      enable = true;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-goodix;
    };

    fwupd.enable = true;
    usbmuxd.enable = true;
  };

  virtualisation = {
    containers.enable = true;

    docker.enable = true;
    docker.storageDriver = "btrfs";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.05"; # Did you read the comment?
}
