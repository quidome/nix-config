{ pkgs, ... }:
{
  imports = [
    ./shared.nix
    ./system-vars.nix
    ./networking.nix
    ./hardware-configuration.nix
    ../../modules
  ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 7;
    windows."11".efiDeviceHandle = "FS0";
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "vm.swappiness" = 1; };
  boot.kernelParams = [
    "consoleblank=60"
    "ip=:::::enp4s0:dhcp"
  ];

  boot.initrd = {
    # availableKernelModules = [ "r8169" ];
    # network.enable = true;

    # clevis.enable = true;
    # clevis.useTang = true;
    # clevis.devices."cryptroot" = /etc/secrets/initrd/clevis-cryptroot.jwe;

    luks.devices."cryptroot" = {
      device = "/dev/disk/by-uuid/345de9be-3f63-43e3-bfa8-eeaddbe8c2c0";
      preLVM = true;
    };
  };

  environment.systemPackages = with pkgs; [
    clevis
    dracut
    heroic
    mangohud
  ];

  networking.hostName = "beast";
  networking.firewall.enable = true;
  networking.networkmanager.enable = true;

  time.hardwareClockInLocalTime = true;
  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_IE.UTF-8";

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      input.General.UserspaceHID = true;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };

  };

  programs = {
    steam.enable = true;
    virt-manager.enable = true;
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  users.groups.libvirtd.members = [ "quidome" ];

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
