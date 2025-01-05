{ pkgs, ... }:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ./shared.nix
    ./system-vars.nix
    ../../modules
  ];

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
    bluetooth.input = {
      General.UserspaceHID = true;
    };
    graphics = {
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
    libva-utils
  ];

  powerManagement.enable = true;

  programs.steam.enable = true;

  services = {
    printing.enable = true;

    logind.extraConfig = "HandlePowerKey=suspend";
  };


  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    autoPrune.dates = "weekly";
  };


  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "22.11"; # Did you read the comment?
}
