{ lib, ... }:
with lib;
{
  imports = [
    ./my.nix

    ./desktop
    ./services
    ./wayland.nix
    ./workstation.nix
  ];

  programs.gnupg.agent.enable = mkDefault true;
  programs.zsh.enable = mkDefault true;

  services.openssh.enable = mkDefault true;
}
