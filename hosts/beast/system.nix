{ pkgs, ... }:
{
  imports = [
    ./shared.nix
    ./system-vars.nix
    ./networking.nix
    ./hardware-configuration.nix
    ../../modules
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "vm.swappiness" = 1; };
  boot.kernelParams = [ "consoleblank=60" ];

  boot.initrd = {
    luks.devices.cryptroot = {
      device = "/dev/disk/by-uuid/345de9be-3f63-43e3-bfa8-eeaddbe8c2c0";
      preLVM = true;
    };
  };

  environment.systemPackages = with pkgs; [
    clevis
    heroic
    mangohud
    factorio-demo
  ];

  networking.hostName = "beast";
  networking.firewall.enable = true;

  time.hardwareClockInLocalTime = true;
  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_IE.UTF-8";

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    bluetooth.input.General.UserspaceHID = true;

    graphics.enable32Bit = true;
    # graphics.extraPackages = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime ];
  };

  programs = {
    gamescope.enable = true;
    steam.enable = true;
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  virtualisation.docker.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
