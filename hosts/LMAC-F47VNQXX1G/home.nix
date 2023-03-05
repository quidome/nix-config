{ nixpkgs, config, pkgs, lib, ... }:

{
  imports = [
    ../../home
    ./vars.nix
  ];

  home = {
    username = "qmeijer";
    stateVersion = "22.11";
    packages = with pkgs; [
      # Basic tools
      coreutils
      curl
      wget
      gopass
      dog
      fd
      fzf
      ripgrep
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
      discord
      gimp
      rectangle

      # Useful nix related tools
      cachix # adding/managing alternative binary caches hosted by Cachix
      comma # run software from without installing it
      niv # easy dependency management for nix projects
      nixpkgs-fmt
      rnix-lsp # nix language server

    ] ++ lib.optionals stdenv.isDarwin [
      cocoapods
      m-cli # useful macOS CLI commands
    ];
  };

  programs = {
    alacritty.enable = true;

    bat.enable = true;
    bat.config.theme = "DarkNeon";
    bat.config.style = "header,snip";

    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    git.enable = true;

    htop.enable = true;
    htop.settings.show_program_path = true;

    exa.enable = true;
    exa.enableAliases = true;

    ssh.enable = true;
    ssh.extraConfig = "AddKeysToAgent yes";

    tmux.enable = true;

    zsh.enable = true;
  };

  # Misc configuration files --------------------------------------------------------------------{{{

}
