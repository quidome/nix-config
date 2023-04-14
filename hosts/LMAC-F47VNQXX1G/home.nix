{ nixpkgs, config, pkgs, lib, ... }:
{
  imports = [
    ./home-brew.nix
    ./home-vars.nix

    ../../home
  ];

  my.profile = "workstation";

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
