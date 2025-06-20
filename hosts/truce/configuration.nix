{...}: {
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
    kernelParams = ["consoleblank=60"];
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
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "24.11"; # Did you read the comment?
}
