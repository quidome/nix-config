{pkgs, ...}: {
  imports = [
    ./disk-config.nix
    ./vars.nix
    ./hardware-configuration.nix
  ];

  boot = {
    initrd = {
      availableKernelModules = ["r8169"];
      network.enable = true;
      systemd = {
        enable = true;
        network = {
          enable = true;
          networks."10-enp42s0" = {
            matchConfig.Name = "enp42s0";
            networkConfig.DHCP = "yes";
            linkConfig.RequiredForOnline = true;
          };
        };
      };
      clevisLuksAskpass = {
        enable = true;
        useTang = true;
      };
    };

    loader.systemd-boot = {
      configurationLimit = 7;
      windows."11".efiDeviceHandle = "FS0";
    };

    kernelParams = [
      "consoleblank=180"
      "ip=:::::enp42s0:dhcp"
    ];
    supportedFilesystems.zfs = true;
  };

  environment.systemPackages = with pkgs; [
    zfs

    # devops
    # don't install jetbrains.ide at this moment as the install never seems to end
    # jetbrains.idea-oss
    postgresql

    # multimedia
    obs-studio
    # obs-studio-plugins

    # heroic
    mangohud
    # lutris
    gogdl
    itch
    mesa-demos
    vulkan-tools
    clinfo
    libva-utils
    lact
    amdgpu_top
    nvtopPackages.amd
    streamcontroller
  ];

  settings = {
    formFactor = "desktop";
    roles = {
      dev.enable = true;
      gaming.enable = true;
      media.enable = true;
      personal.enable = true;
    };
  };

  networking = {
    hostName = "bea";
    firewall.enable = true;

    # Disable secondary interface to prevent IPv6 routing conflicts
    interfaces.enp47s0f3u3u3.useDHCP = false;
    networkmanager.unmanaged = ["enp47s0f3u3u3"];
  };

  time.hardwareClockInLocalTime = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs = {
    appimage.enable = true;
    appimage.binfmt = true;
    gamemode = {
      enable = true;
      enableRenice = true;
    };
    java.enable = true;
    steam = {
      enable = true;
      extraPackages = with pkgs; [
        gamemode
        jdk
        mangohud
      ];
      extraCompatPackages = with pkgs; [proton-ge-bin];
      protontricks.enable = true;
    };
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  system.stateVersion = "26.05";
}
