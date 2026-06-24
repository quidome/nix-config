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
    btop
    fd
    fzf
    ripgrep
    tree

    # network
    curl
    dig
    tcpdump
    traceroute

    # devops
    gh
    git
    git-crypt
    git-repo-updater
    gitui

    # tools
    gnupg
    gopass
    helix
    jless
    jq
    just
    neovim
    rename
    rtk
    yamllint
    yq-go

    # devops tooling
    alejandra
    cilium-cli
    claude-code
    deadnix
    pi-coding-agent
    deadnix
    helmfile
    ipcalc
    k9s
    kubectl
    kubectx
    kubernetes-helm
    kubeseal
    kustomize
    pi
    python3
    shellcheck
    statix
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
