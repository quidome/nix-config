{ lib, pkgs, config, ... }:
{
  imports = [
    ./shared.nix
    ./system-vars.nix
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

    wireless = lib.mkIf (! config.networking.networkmanager.enable) {
      enable = true;
      userControlled.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [ calibre ];

  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "weekly";

  services.fprintd = {
    enable = true;
    tod.enable = true;
    tod.driver = pkgs.libfprint-2-tod1-goodix;
  };

  services.fwupd.enable = true;

  services.tailscale.enable = true;
  services.usbmuxd.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.05"; # Did you read the comment?
}
