{
  config,
  lib,
  ...
}: let
  c = import ../theme/palette.nix config.settings.theme;
in {
  home = {
    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
      "${config.home.homeDirectory}/bin"
    ];
  };
  programs = {
    bat = {
      enable = true;
      config = {
        style = "header,snip";
        theme = "Catppuccin ${c.flavorTitle}";
      };
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    git.enable = true;

    helix.enable = true;

    htop = {
      enable = true;
      settings.show_program_path = true;
    };

    neovim.enable = true;

    # comma (run a program without installing it), with its package database.
    nix-index-database.comma.enable = true;

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        ForwardAgent = false;
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };

    zellij.enable = lib.mkDefault true;

    zoxide.enable = true;

    zsh = {
      enable = true;
      initContent = "fpath+=($HOME/.zsh/completion/)";
    };
  };
}
