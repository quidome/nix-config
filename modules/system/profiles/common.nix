{
  claude-code,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
with lib; let
  herdr = pkgs.stdenvNoCC.mkDerivation {
    pname = "herdr";
    version = "0.8.2";

    src = pkgs.fetchurl {
      url = "https://github.com/herdrdev/herdr/releases/download/v0.8.2/herdr-linux-x86_64";
      hash = "sha256-l2FQoU1JDJSyQ+ouGn6y37Z/EuNrGC25CTb2co5q7PQ=";
    };

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      install -Dm755 "$src" "$out/bin/herdr"
    '';

    meta = {
      description = "Terminal workspace manager for AI coding agents";
      homepage = "https://herdr.dev";
      license = lib.licenses.asl20;
      mainProgram = "herdr";
      platforms = ["x86_64-linux"];
    };
  };
in {
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
  nix.optimise.automatic = mkDefault true;

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
    herdr
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

  programs.zsh.enable = mkDefault true;

  # Home Manager's gpg-agent provides the SSH agent; keep gnome-keyring's GCR agent off.
  services.gnome.gcr-ssh-agent.enable = false;
  services.openssh.enable = mkDefault true;
}
