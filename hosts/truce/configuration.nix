{...}: {
  imports = [
    ./disk-config.nix
    ./vars.nix
    ./hardware-configuration.nix
  ];

  settings = {
    formFactor = "laptop";
    roles = {
      dev.enable = true;
      personal.enable = true;
    };
  };

  boot.kernelParams = ["consoleblank=60"];

  networking = {
    hostName = "truce";
    firewall.enable = true;
  };

  system.stateVersion = "26.05";
}
