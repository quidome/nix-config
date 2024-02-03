{ lib, ... }:
{
  imports = [
    ./system-vars.nix
    ./hardware-configuration.nix
    ../../modules
  ];

  my.gui = "sway";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "vm.swappiness" = 1; };

  # crypto_LUKS /dev/sda3 - swap
  boot.initrd.luks.devices."luks-d1cc9c47-a9e6-4e8a-92c8-92155208f018".device = "/dev/disk/by-uuid/d1cc9c47-a9e6-4e8a-92c8-92155208f018";

  networking.hostName = "truce";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_IE.UTF-8";

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  programs = {
    gnupg.agent.enable = true;
    gnupg.agent.enableSSHSupport = true;
  };

  services.auto-cpufreq.enable = true;
  services.usbmuxd.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "22.11"; # Did you read the comment?
}
