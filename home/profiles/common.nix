{
  config,
  lib,
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      alejandra
      cilium-cli
      helmfile
      httpie
      ipcalc
      k9s
      kubectl
      kubectx
      kubernetes-helm
      kubeseal
      kustomize
      rename
      stern
    ];

    sessionPath = [
      "${config.home.homeDirectory}/bin"
      "${config.home.homeDirectory}/go/bin"
      "${config.home.homeDirectory}/.cargo/bin"
    ];

    sessionVariables = {
      DEV_PATH = "${config.home.homeDirectory}/dev";
    };
  };
  programs.bat.enable = true;
  programs.bat.config.theme = "DarkNeon";
  programs.bat.config.style = "header,snip";

  programs.delta.enable = true;
  programs.delta.enableGitIntegration = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.eza.enable = true;
  programs.eza.enableZshIntegration = true;
  programs.eza.extraOptions = [
    "--group-directories-first"
    "--header"
  ];

  programs.git.enable = true;

  programs.helix.enable = true;

  programs.home-manager.enable = true;

  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;
  programs.ssh.matchBlocks."*" = {
    addKeysToAgent = "yes";
    compression = false;
    controlMaster = "no";
    controlPath = "~/.ssh/master-%r@%n:%p";
    controlPersist = "no";
    forwardAgent = true;
    hashKnownHosts = false;
    serverAliveCountMax = 3;
    serverAliveInterval = 0;
    userKnownHostsFile = "~/.ssh/known_hosts";
  };

  programs.zellij.enable = lib.mkDefault true;

  programs.zoxide.enable = true;

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.initContent = "fpath+=($HOME/.zsh/completion/)";
  programs.zsh.shellAliases = {
    "k" = "kubectl";
    "kc" = "kubectx";
    "kn" = "kubens";
    "kseal" = "kubeseal --controller-namespace kube-system --controller-name sealed-secrets";
  };
}
