{ ... }:
{
  imports = [
    ./system-vars.nix
    ./hardware-configuration.nix
    ../../modules
  ];

  my.gui = "gnome";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "vm.swappiness" = 1; };
  boot.kernelParams = [ "consoleblank=60" ];

  # crypto_LUKS /dev/sda3 - swap
  boot.initrd.luks.devices."luks-d1cc9c47-a9e6-4e8a-92c8-92155208f018".device = "/dev/disk/by-uuid/d1cc9c47-a9e6-4e8a-92c8-92155208f018";

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_IE.UTF-8";

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  networking.firewall.enable = true;
  networking.hostName = "truce";
  # networking.wireless = {
  #   enable = true;
  #   interfaces = [ "wlp2s0" ];
  #   userControlled.enable = true;
  # };

  # systemd.network = {
  #   enable = true;
  #   networks."10-wlan" = {
  #     matchConfig.Name = "wlp2s0";
  #     networkConfig.DHCP = "ipv4";
  #   };
  # };
  };

  programs = {
    gnupg.agent.enable = true;
    gnupg.agent.enableSSHSupport = true;
  };

  services.usbmuxd.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "22.11"; # Did you read the comment?
}
