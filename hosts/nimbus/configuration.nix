{pkgs, ...}: {
  imports = [
    ./disk-config.nix
    ./shared.nix
    ./vars.nix
    ./hardware-configuration.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernel.sysctl = {"vm.swappiness" = 1;};
    kernelParams = [
      "consoleblank=60"
      "zswap.enabled=1"
      "zswap.compression=zstd"
      "zswap.zpool=zsmalloc"
      "zswap.max_pool_percent=50"
    ];
  };

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_IE.UTF-8";

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    cpu.intel.updateMicrocode = true;
    graphics.enable = true;
    graphics.extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  networking = {
    hostName = "nimbus";
    firewall.enable = true;
    networkmanager.enable = true;

    wg-quick.interfaces.wg0 = {
      autostart = false;
      address = ["172.16.41.14/32"];
      dns = ["172.16.40.1" "lan.balti.casa"];
      listenPort = 51820;
      privateKeyFile = "/etc/secrets/wg0-private";

      peers = [
        {
          publicKey = "YkOAj87heEGLFgM8h1VhsBfBp1qYgpcpTAz9NUOTTQU=";
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "wg.quido.me:51232";
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    # devops
    jetbrains.idea-community
    temurin-bin-21
    ktlint

    # multimedia
    kdePackages.kdenlive
    krita
    digikam

    # games
    openttd
    zeroad

    # printing
    blender
    orca-slicer

    calibre
    gimp

    # gaming
    discord
    openttd

    docker-compose
    lazydocker

    libimobiledevice
    ifuse
    virt-manager
    wireshark
  ];

  powerManagement.enable = true;

  services = {
    fprintd = {
      enable = true;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-goodix;
    };

    fwupd.enable = true;
    usbmuxd.enable = true;
  };

  virtualisation = {
    containers.enable = true;

    docker.enable = true;
    docker.storageDriver = "btrfs";
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "25.11";
}
