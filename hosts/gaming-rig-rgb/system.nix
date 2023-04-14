{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./zfs-configuration.nix
    ../../modules
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "vm.swappiness" = 1; };

  networking.hostName = "gaming-rig-rgb";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IE.UTF-8";

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  users.users.quidome = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  programs = {
    gnupg.agent.enable = true;
    gnupg.agent.enableSSHSupport = true;
  };

  services = {
    openssh.enable = true;
    pipewire.enable = true;

    xserver.desktopManager.plasma5.enable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "22.11"; # Did you read the comment?
}
