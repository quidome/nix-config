{ lib, ... }:
with lib;
{
  programs.zsh.enable = mkDefault true;
  programs.gnupg.agent.enable = mkDefault true;

  services.openssh.enable = mkDefault true;
}
