{
  config,
  lib,
  ...
}: let
  isLight = config.settings.theme == "light";
  batTheme =
    if isLight
    then "Catppuccin Latte"
    else "Catppuccin Mocha";
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
        theme = batTheme;
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
