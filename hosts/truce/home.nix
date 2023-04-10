{ config, ... }:
{
  home = {
    stateVersion = "22.11";
    user = "quidome";
    homeDirectory = "/home/quidome";
  };

  programs.home-manager.enable = true;
}
