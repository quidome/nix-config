{ lib, pkgs, ... }:
with lib;
{
  environment.systemPackages = with pkgs; [
    git
    git-crypt
    home-manager
    vim

    # system
    bottom
    fd
    fzf
    gnupg
    ripgrep

    # network
    curl
    dogdns
    wget

    # devops
    gitui
    go
    shellcheck
    yq-go

    # tools
    bitwarden-cli
    gopass
    jless
    jq
    rcm

    # Useful nix related tools
    cachix # adding/managing alternative binary caches hosted by Cachix
    comma # run software from without installing it
    niv # easy dependency management for nix projects
    nixpkgs-fmt
  ];

  programs.gnupg.agent.enable = mkDefault true;
  programs.zsh.enable = mkDefault true;

  services.openssh.enable = mkDefault true;
}
