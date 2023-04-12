{ nixpkgs, config, pkgs, lib, ... }:
{
  imports = [
    ../../home
    ../../home/profile/workstation.nix
    ./vars.nix
  ];

  home = {
    stateVersion = "22.11";
    packages = with pkgs; [
      rcm
      pinentry_mac

      colima
      docker-client
      docker-compose
      docker-credential-helpers
      k9s
      kubectx
      stern
    ];

    sessionPath = [
      "/Applications/IntelliJ IDEA.app/Contents/MacOS"
    ];
  };
}
