{
  lib,
  pkgs,
  ...
}:
with lib; {
  boot = {
    loader.systemd-boot.enable = mkDefault true;
    loader.efi.canTouchEfiVariables = mkDefault true;
    zfs.forceImportRoot = mkDefault false;
    kernel.sysctl = {"vm.swappiness" = mkDefault 1;};
  };

  time.timeZone = mkDefault "Europe/Amsterdam";

  i18n.defaultLocale = mkDefault "en_IE.UTF-8";

  hardware.bluetooth = {
    enable = mkDefault true;
    powerOnBoot = mkDefault true;
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  environment.systemPackages = with pkgs; [
    # system
    bottom
    fd
    fzf
    gnupg
    ripgrep
    tree

    # network
    curl
    dig
    tcpdump
    wget

    # devops
    git
    gh
    git-crypt
    git-repo-updater
    gitui
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
    rtk
    yamllint
    vim

    # devops tooling
    alejandra
    deadnix
    statix
    cilium-cli
    claude-code
    deadnix
    pi-coding-agent
    helmfile
    ipcalc
    k9s
    kubectl
    kubectx
    kubernetes-helm
    kubeseal
    kustomize
    python3
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
