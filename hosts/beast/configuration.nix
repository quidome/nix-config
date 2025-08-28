{pkgs, ...}: {
  imports = [
    ./disk-config.nix
    ./shared.nix
    ./vars.nix
    ./networking.nix
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 7;
    windows."11".efiDeviceHandle = "FS0";
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = {"vm.swappiness" = 1;};
  boot.kernelParams = ["consoleblank=180"];

  environment.systemPackages = with pkgs; [
    heroic
    mangohud
    lutris
    gogdl
    itch
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

    amdgpu.amdvlk = {
      enable = true;
      support32Bit.enable = true;
    };
  };

  programs.appimage.enable = true;

  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
  programs.virt-manager.enable = true;

  services.flatpak.enable = true;
  services.xserver.videoDrivers = ["amdgpu"];

  users.groups.libvirtd.members = ["quidome"];

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "25.05";
}
