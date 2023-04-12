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
      # dev tools
      go
      jless
      pandoc
      pipenv
      plantuml
      poetry
      postgresql
      shellcheck
      yq-go

      # Docker/Cloud
      gitui
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
