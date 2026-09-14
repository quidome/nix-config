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
      "${config.home.homeDirectory}/go/bin"
      "${config.home.homeDirectory}/.cargo/bin"
    ];

    sessionVariables = {
      DEV_PATH = "${config.home.homeDirectory}/dev";
      GOBIN = "${config.home.homeDirectory}/.local/bin";
      PI_CODING_AGENT_DIR = "${config.home.homeDirectory}/dev/codeberg.org/quidome/pi-config";
      PI_EXTENSIONS = "${config.home.homeDirectory}/dev/codeberg.org/quidome/pi-extensions/extensions";
    };
  };
  programs = {
    bat = {
      enable = true;
      config = {
        style = "header,snip";
        theme = batTheme;
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
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

    jujutsu = {
      enable = true;
      ediff = true;
    };

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
      shellAliases = {
        "k" = "kubectl";
        "kc" = "kubectx";
        "kn" = "kubens";
        "kseal" = "kubeseal --controller-namespace kube-system --controller-name sealed-secrets";
      };
    };
  };
}
