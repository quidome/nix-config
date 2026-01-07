{
  lib,
  pkgs,
  ...
}:
with lib; {
  environment.systemPackages = with pkgs; [
    # system
    bottom
    fd
    fzf
    gnupg
    ripgrep

    # network
    curl
    dogdns
    httpie
    tcpdump
    wget

    # devops
    git
    git-crypt
    git-repo-updater
    gitui
    opencode
    shellcheck
    yq-go

    # tools
    bitwarden-cli
    gopass
    helix
    jless
    jq
    just
    rename
    vim

    # devops tooling
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
    stern

    # Useful nix related tools
    cachix # adding/managing alternative binary caches hosted by Cachix
    comma # run software from without installing it
    niv # easy dependency management for nix projects
  ];

  programs.gnupg.agent.enable = mkDefault true;
  programs.zsh.enable = mkDefault true;

  services.openssh.enable = mkDefault true;
}
