{ ... }:
{
  imports = [
    ./shared.nix
    ./system-vars.nix
    ./hardware-configuration.nix
    ../../modules
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernel.sysctl = { "vm.swappiness" = 1; };
    kernelParams = [ "consoleblank=60" ];

    # crypto_LUKS /dev/sda3 - swap
    initrd.luks.devices."luks-d1cc9c47-a9e6-4e8a-92c8-92155208f018".device = "/dev/disk/by-uuid/d1cc9c47-a9e6-4e8a-92c8-92155208f018";
  };

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_IE.UTF-8";

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  networking = {
    hostName = "truce";
    firewall.enable = true;
    networkmanager.enable = true;

    wg-quick.interfaces.wg0 = {
      autostart = false;
      address = [ "172.16.41.14/32" ];
      dns = [ "172.16.41.1" "lan.balti.casa" "balti.casa" "quido.me" ];
      listenPort = 51820;
      privateKeyFile = "/etc/secrets/wg0-private";

      peers = [
        {
          publicKey = "YkOAj87heEGLFgM8h1VhsBfBp1qYgpcpTAz9NUOTTQU=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "wg.quido.me:51232";
        }
      ];
    };
  };

  services.tailscale.enable = true;
  services.usbmuxd.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "22.11"; # Did you read the comment?
}
