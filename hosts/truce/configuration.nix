{...}: {
  imports = [
    ./disk-config.nix
    ./shared.nix
    ./vars.nix
    ./hardware-configuration.nix
  ];

  boot.kernelParams = ["consoleblank=60"];

  networking = {
    hostName = "truce";
    firewall.enable = true;
    networkmanager.enable = true;
  };

  powerManagement.enable = true;

  system.stateVersion = "26.05";
}
