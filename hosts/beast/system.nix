{ pkgs, config, ... }:
{
  imports = [
    ./shared.nix
    ./system-vars.nix
    ./hardware-configuration.nix
    ../../modules
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "vm.swappiness" = 1; };
  boot.kernelParams = [ "consoleblank=60" ];

  boot.supportedFilesystems = [ "bcachefs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd = {
    availableKernelModules = [ "r8169" ];
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };
    };

    # Unlock bcachefs over ssh
    systemd =
      let
        askPass = pkgs.writeShellScriptBin "bcachefs-askpass" ''
          keyctl link @u @s
          mkdir /sysroot
          until bcachefs mount /dev/vda1 /sysroot
          do
            sleep  1
          done
        '';
      in
      {
        enable = true;
        initrdBin = with pkgs; [ keyutils ];
        storePaths = [ "${askPass}/bin/bcachefs-askpass" ];
        users.root.shell = "${askPass}/bin/bcachefs-askpass";
        network.enable = true;
        network.networks."10-lan" = {
          matchConfig.Name = "enp1s0";
          networkConfig.DHCP = "yes";
        };
      };

    clevis = {
      enable = true;
      useTang = true;
      devices."${config.fileSystems."/".device}".secretFile = /etc/secrets/initrd/clevis-bcachefs.jwe;
    };
  };

  environment.systemPackages = with pkgs; [
    # heroic
    # mangohud
    # factorio-demo
    git
    git-crypt
    clevis
    helix
    fd
    ripgrep
  ];

  networking.firewall.enable = true;
  networking.hostName = "beast-vm";
  networking.networkmanager.enable = true;

  # time.hardwareClockInLocalTime = true;
  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_IE.UTF-8";

  # hardware = {
  #   bluetooth.enable = true;
  #   bluetooth.powerOnBoot = true;
  #   bluetooth.input.General.UserspaceHID = true;

  #   opengl.driSupport32Bit = true;
  #   opengl.extraPackages = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime ];
  # };

  # programs = {
  #   gamescope.enable = true;
  #   steam.enable = true;
  # };

  # services.xserver.videoDrivers = [ "amdgpu" ];

  virtualisation.docker.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.05";
}
