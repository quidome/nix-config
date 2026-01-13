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
    # devops
    jetbrains.idea-community
    ktlint
    postgresql
    temurin-bin-21
    kubectl
    kustomize
    kubernetes-helm
    cilium-cli
    k9s

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
  networking.networkmanager.enable = false;

  time.hardwareClockInLocalTime = true;
  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_IE.UTF-8";

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    input.General.UserspaceHID = true;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  programs.java.enable = true;
  # programs.steam = {
  #   enable = true;
  #   extraPackages = with pkgs; [jdk];
  #   extraCompatPackages = with pkgs; [proton-ge-bin];
  # };

  services.flatpak.enable = true;
  services.xserver.videoDrivers = ["amdgpu"];

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "25.11";
}
