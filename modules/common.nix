{ lib, ...}:
{
  programs.zsh.enable = lib.mkDefault true;
  programs.gnupg.agent.enable = mkDefault true;
}
