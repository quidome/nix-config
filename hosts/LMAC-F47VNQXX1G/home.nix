{ nixpkgs, config, pkgs, lib, ... }:

{
  imports = [
    ../../home
    ./vars.nix
  ];

  my = {
    programs.alacritty.enable = true;
    programs.git.enable = true;
    programs.tmux.enable = true;
    programs.zsh.enable = true;
  };

  home = {
    username = "qmeijer";
    stateVersion = "22.11";
    packages = with pkgs;
      [
        # Basic tools
        coreutils
        curl
        wget
        gopass
        bat
        dog
        fd
        fzf
        ripgrep
        rcm
        gnupg
        pinentry_mac
        watch

        # dev tools
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

        # Useful nix related tools
        cachix # adding/managing alternative binary caches hosted by Cachix
        comma # run software from without installing it
        niv # easy dependency management for nix projects
        rnix-lsp # nix language server

      ] ++ lib.optionals stdenv.isDarwin [
        cocoapods
        m-cli # useful macOS CLI commands
      ];
  };

  programs = {
    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    htop.enable = true;
    htop.settings.show_program_path = true;

    exa.enable = true;
    exa.enableAliases = true;

    ssh.enable = true;
    ssh.extraConfig = "AddKeysToAgent yes";
  };

  # Misc configuration files --------------------------------------------------------------------{{{

}
