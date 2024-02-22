{ pkgs, ... }:
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
  boot.kernelParams = [ "ip=dhcp" "consoleblank=60" ];

  boot.initrd = {
    luks.devices.cryptroot = {
      device = "/dev/disk/by-uuid/345de9be-3f63-43e3-bfa8-eeaddbe8c2c0";
      preLVM = true;
    };

    network.enable = true;
    network.ssh = {
      enable = true;
      hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      port = 2222;
      shell = "/bin/cryptsetup-askpass";
    };
  };

  networking.firewall.enable = true;
  networking.hostName = "beast";

  networking.networkmanager.enable = false;
  systemd.network.enable = true;
  systemd.network.networks = {
    # "10-lan" = { matchConfig.Name = "enp4s0"; networkConfig.DHCP = "ipv4"; dhcpV4Config.UseDomains = true; };
    "11-lan" = { matchConfig.Name = "enp42s0"; networkConfig.DHCP = "ipv4"; dhcpV4Config.UseDomains = true; };
  };

  time.hardwareClockInLocalTime = true;
  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_IE.UTF-8";

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    bluetooth.input = {
      General.UserspaceHID = true;
    };

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
