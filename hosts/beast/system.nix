{ config, pkgs, ... }:
{
  imports = [
    ./system-vars.nix
    ./hardware-configuration.nix
    ./zfs-configuration.nix
    ../../modules
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "vm.swappiness" = 1; };

  networking.hostName = "beast";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.hardwareClockInLocalTime = true;
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IE.UTF-8";

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;

    nvidia.modesetting.enable = true;
  };

  programs = {
    gnupg.agent.enable = true;
    gnupg.agent.enableSSHSupport = true;

    steam.enable = true;
  };

  services = {
    openssh.enable = true;
    pipewire.enable = true;

    xserver.desktopManager.plasma5.enable = true;
    xserver.videoDrivers = [ "nvidia" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "22.11"; # Did you read the comment?
}
