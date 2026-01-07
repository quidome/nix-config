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
  boot = {
    extraModprobeConfig = "options hid_apple swap_opt_cmd=1";

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernel.sysctl = {"vm.swappiness" = 1;};
    kernelParams = ["consoleblank=60"];
  };

  networking = {
    hostName = "coolding";
    networkmanager.enable = true;
    enableB43Firmware = true;
  };

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
    discord
    blender

    libva-utils
  ];

  powerManagement.enable = true;

  services.printing.enable = true;
  services.logind.settings.Login = {HandlePowerKey = "suspend";};
  services.xserver.videoDrivers = ["intel"];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "25.11"; # Did you read the comment?
}
