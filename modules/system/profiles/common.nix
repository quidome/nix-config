{
  claude-code,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: {
  boot = {
    loader.systemd-boot.enable = lib.mkDefault true;
    loader.efi.canTouchEfiVariables = lib.mkDefault true;
    zfs.forceImportRoot = lib.mkDefault false;
    kernel.sysctl = {"vm.swappiness" = lib.mkDefault 1;};
  };

  time.timeZone = lib.mkDefault "Europe/Amsterdam";

  i18n.defaultLocale = lib.mkDefault "en_IE.UTF-8";

  hardware.bluetooth = {
    enable = lib.mkDefault true;
    powerOnBoot = lib.mkDefault true;
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.optimise.automatic = lib.mkDefault true;

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
    mtr
    tcpdump
    traceroute
    wget

    # devops
    gh
    git
    git-crypt
    git-repo-updater
    gitui
    lazygit

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
    cilium-cli
    helmfile
    ipcalc
    k9s
    kubectl
    kubectx
    kubernetes-helm
    kubeseal
    kustomize
    claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgsUnstable.pi-coding-agent
    python3
    shellcheck
    stern

    # Useful nix related tools
    alejandra
    cachix # adding/managing alternative binary caches hosted by Cachix
    comma # run software from without installing it
    deadnix
    statix
  ];

  programs.zsh.enable = lib.mkDefault true;

  services.openssh.enable = lib.mkDefault true;
}
