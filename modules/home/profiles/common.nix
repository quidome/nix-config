{
  config,
  lib,
  pkgs,
  ...
}: {
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
      PI_CODING_AGENT_DIR = "${config.home.homeDirectory}/dev/github.com/quidome/pi-config";
      PI_EXTENSIONS = "${config.home.homeDirectory}/dev/github.com/quidome/pi-extensions/extensions";
    };
  };
  programs = {
    bat = {
      enable = true;
      config.style = "header,snip";
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
      matchBlocks."*" = {
        forwardAgent = false;
        addKeysToAgent = "yes";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
    };

    zellij.enable = lib.mkDefault true;

    zoxide.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      initContent = "fpath+=($HOME/.zsh/completion/)";
      shellAliases = {
        "k" = "kubectl";
        "kc" = "kubectx";
        "kn" = "kubens";
        "kseal" = "kubeseal --controller-namespace kube-system --controller-name sealed-secrets";
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = false;
    defaultCacheTtl = 3600;
    maxCacheTtl = 14400;
    pinentry.package = lib.mkDefault pkgs.pinentry-curses;
  };
}
