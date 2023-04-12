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
      gopass
      rcm

      # dev tools
      go
      jless
      jq
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
      git-crypt
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
    git.enable = true;

    htop.enable = true;
    htop.settings.show_program_path = true;

    ssh.enable = true;

    tmux.enable = true;

    zsh.enable = true;
  };
}
