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
    home-manager

    # network
    curl
    dogdns
    wget

    # devops
    git
    git-crypt
    gitui
    shellcheck
    yq-go

    # tools
    bitwarden-cli
    gopass
    helix
    jless
    jq
    vim

    # Useful nix related tools
    cachix # adding/managing alternative binary caches hosted by Cachix
    comma # run software from without installing it
    niv # easy dependency management for nix projects
  ];

  programs.gnupg.agent.enable = mkDefault true;
  programs.zsh.enable = mkDefault true;

  services.openssh.enable = mkDefault true;
}
