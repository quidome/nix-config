{ nixpkgs, config, pkgs, lib, ... }:
{
  imports = [
    ./homebrew.nix
    ./vars.nix

    ../../home
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
