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
      # Basics
      rcm
      pinentry_mac

      # Dev
      fnm

      # Docker/k8s
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

  programs.zsh.initExtra = ''
    eval "$(fnm env --use-on-cd)";
  '';
}
