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
}
