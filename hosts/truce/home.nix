{ config, pkgs, lib, ... }:
{
  imports = [
    ../../home
    ../../home/vscode.nix
    ./vars.nix
  ];

  home = {
    stateVersion = "22.11";
    packages = with pkgs; [
      # Basic tools
      rcm

      # dev tools
      go
      jless
      maven
      pandoc
      pipenv
      plantuml
      poetry
      postgresql
      shellcheck
      yq-go

      # Docker/Cloud
      gitui
      docker-client
      docker-compose
      docker-credential-helpers
      k9s
      kubectx
      stern

      # other apps
      bitwarden-cli
      discord
      gimp
    ];
  };

  programs.home-manager.enable = true;
  programs = {
    alacritty.enable = true;

    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    firefox.enable = true;
  };
}
