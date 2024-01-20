{ config, pkgs, ... }:
{
  imports = [
    ./system-vars.nix
    ./hardware-configuration.nix
    ../../modules
  ];

  my.gui = "kde";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "vm.swappiness" = 1; };

  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-uuid/345de9be-3f63-43e3-bfa8-eeaddbe8c2c0";
    preLVM = true;
  };

  networking.hostName = "beast";
  networking.networkmanager.enable = true;

  time.hardwareClockInLocalTime = true;
  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_IE.UTF-8";

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;

    opengl.driSupport32Bit = true;
    opengl.extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };

  programs = {
    gnupg.agent.enable = true;
    gnupg.agent.enableSSHSupport = true;

    steam.enable = true;
  };

  services = {
    xserver.videoDrivers = [ "amdgpu" ];
  };

  virtualisation = {
    docker = {
      enable = true;
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
