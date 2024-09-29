{ lib, pkgs, ... }:
with lib;
{
  environment.systemPackages = with pkgs; [
    git
    git-crypt
    home-manager
  ];

  programs.gnupg.agent.enable = mkDefault true;
  programs.zsh.enable = mkDefault true;

  services.openssh.enable = mkDefault true;
}
