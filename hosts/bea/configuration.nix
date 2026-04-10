{pkgs, ...}: {
  imports = [
    ./disk-config.nix
    ./shared.nix
    ./vars.nix
    ./networking.nix
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot = {
    configurationLimit = 7;
    windows."11".efiDeviceHandle = "FS0";
  };

  boot.kernelParams = ["consoleblank=180"];
  boot.supportedFilesystems.zfs = true;

  environment.systemPackages = with pkgs; [
    zfs

    # devops
    # don't install jetbrains.ide at this moment as the install never seems to end
    # jetbrains.idea-oss
    ktlint
    postgresql
    temurin-bin-21

    # multimedia
    kdePackages.kdenlive

    # games
    openttd
    zeroad

    # printing
    blender
    orca-slicer

    heroic
    mangohud
    lutris
    gogdl
    itch
    mesa-demos
    vulkan-tools
    clinfo
    libva-utils
    lact
    amdgpu_top
    nvtopPackages.amd
  ];

  networking.hostName = "bea";
  networking.firewall.enable = true;
  networking.networkmanager.enable = true;

  # Disable secondary interface to prevent IPv6 routing conflicts
  networking.interfaces.enp47s0f3u3u3.useDHCP = false;
  networking.networkmanager.unmanaged = ["enp47s0f3u3u3"];

  time.hardwareClockInLocalTime = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  programs.java.enable = true;
  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [jdk];
    extraCompatPackages = with pkgs; [proton-ge-bin];
  };

  services.xserver.videoDrivers = ["amdgpu"];

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  system.stateVersion = "25.11";
}
