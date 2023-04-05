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
      yq

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

    sessionPath = [
      "${config.home.homeDirectory}/bin"
      "${config.home.homeDirectory}/go/bin"
      "${config.home.homeDirectory}/.cargo/bin"
      "/Applications/IntelliJ IDEA.app/Contents/MacOS"
    ];

    sessionVariables = {
      DEV_PATH = "${config.home.homeDirectory}/dev";
    };
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
