{pkgs, ...}: let
  my-python-packages = ps:
    with ps; [
      pip
    ];
in {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ./shared.nix
    ./vars.nix
  ];
  boot.extraModprobeConfig = "options hid_apple swap_opt_cmd=1";
  boot.kernelParams = ["consoleblank=60"];

  networking = {
    hostName = "coolding";
    firewall.enable = true;
    networkmanager.enable = true;
    enableB43Firmware = true;
  };

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
        intel-media-driver
      ];
    };
  };

  # install packages unique for this host
  environment.systemPackages = with pkgs; [
    # dev tools
    poetry
    (python3.withPackages my-python-packages)

    # some tools
    cointop
    blender

    libva-utils
  ];

  laptop.enable = true;
  powerManagement.enable = true;

  services.logind.settings.Login = {HandlePowerKey = "suspend";};
  services.xserver.videoDrivers = ["intel"];

  system.stateVersion = "25.11"; # Did you read the comment?
}
