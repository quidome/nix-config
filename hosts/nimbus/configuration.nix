{pkgs, ...}: {
  imports = [
    ./disk-config.nix
    ./shared.nix
    ./vars.nix
    ./hardware-configuration.nix
  ];

  boot.kernelParams = [
    "consoleblank=60"
    "zswap.enabled=1"
    "zswap.compression=zstd"
    "zswap.zpool=zsmalloc"
    "zswap.max_pool_percent=50"
  ];

  hardware = {
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
      address = ["10.10.42.3/32"];
      dns = ["172.16.40.78" "srv.balti.casa" "lan.balti.casa" "mgt.balti.casa"];
      privateKeyFile = "/etc/secrets/wg0-private";

      peers = [
        {
          publicKey = "bXHAJ9YbZHInQ8dlEHk9/y1+lwTKhk7ra8sxmiQK6wk=";
          allowedIPs = ["10.10.42.0/24" "172.16.40.0/24"];
          endpoint = "wg.quido.me:51820";
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    # devops
    # don't install jetbrains.ide at this moment as the install never seems to end
    # jetbrains.idea-oss
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

    docker-compose
    lazydocker

    libimobiledevice
    ifuse
    virt-manager
    wireshark
  ];

  powerManagement.enable = true;

  services = {
    btrfs.autoScrub = {
      enable = true;
      fileSystems = ["/"];
      interval = "monthly";
    };

    fprintd = {
      enable = true;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-goodix;
    };

    fwupd.enable = true;
    usbmuxd.enable = true;
  };

  # Enable fingerprint authentication for login and system dialogs
  security.pam.services = {
    sudo.fprintAuth = true;
    polkit-1.fprintAuth = true;
  };

  virtualisation = {
    containers.enable = true;

    docker.enable = true;
    docker.storageDriver = "btrfs";
  };

  system.stateVersion = "26.05";
}
