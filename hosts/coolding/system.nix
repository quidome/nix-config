{ config, pkgs, ... }:
{
  imports = [
    ./system-vars.nix
    ./hardware-configuration.nix
    ../../modules
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "vm.swappiness" = 1; };
  boot.extraModprobeConfig = ''
      options hid_apple swap_opt_cmd=1
    '';

  networking.hostName = "coolding";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_IE.UTF-8";

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;

    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
      ];
    };
  };


  # install packages unique for this host
  environment.systemPackages = with pkgs; [
    cointop
    discord
    libva-utils

    # development
    rnix-lsp
    rustup
  ];


  programs = {
    gnupg.agent.enableSSHSupport = true;
    ssh.startAgent = false;
    steam.enable = true;
  };


  services = {
    flatpak.enable = true;
    openssh.enable = true;
    pipewire.enable = true;
    printing.enable = true;

    logind.extraConfig = "HandlePowerKey=suspend";

    xserver.desktopManager.plasma5.enable = true;
  };


  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    autoPrune.dates = "weekly";
  };


  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "22.11"; # Did you read the comment?
}
