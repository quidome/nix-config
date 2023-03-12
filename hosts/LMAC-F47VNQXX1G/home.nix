{ nixpkgs, config, pkgs, lib, ... }:
{
  imports = [
    ../../home
    ./vars.nix
  ];

  home = {
    stateVersion = "22.11";
    packages = with pkgs; [
      # Basic tools
      coreutils
      gopass
      rcm
      gnupg
      pinentry_mac
      watch

      # dev tools
      pipenv
      poetry
      go
      jq
      jless
      maven
      pandoc
      postgresql
      shellcheck

      # Docker/Cloud
      gitui
      git-crypt
      colima
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
      rectangle

    ] ++ lib.optionals stdenv.isDarwin [
      cocoapods
      m-cli # useful macOS CLI commands
    ];
  };

  programs = {
    alacritty.enable = true;

    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    git.enable = true;

    htop.enable = true;
    htop.settings.show_program_path = true;

    ssh.enable = true;

    tmux.enable = true;

    zsh.enable = true;
  };
}
