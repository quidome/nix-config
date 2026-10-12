{
  lib,
  pkgs,
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

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    # Deduplicate on write; the optimise timer is skipped on battery.
    auto-optimise-store = lib.mkDefault true;
  };
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

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
    ipcalc
    mtr
    tcpdump
    traceroute
    wget

    # git
    git
    git-crypt

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
    yq-go

    # Useful nix related tools
    alejandra
    cachix # adding/managing alternative binary caches hosted by Cachix
    comma # run software from without installing it
    deadnix
    statix
  ];

  programs.zsh.enable = lib.mkDefault true;

  services.openssh.enable = lib.mkDefault true;

  virtualisation = {
    containers.enable = lib.mkDefault true;
    docker = {
      enable = lib.mkDefault true;
      # All hosts use the shared btrfs disk layout (modules/system/disk-config.nix).
      storageDriver = lib.mkDefault "btrfs";
    };
  };
}
