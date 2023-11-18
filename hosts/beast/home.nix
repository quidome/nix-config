{ config, pkgs, lib, ... }:
{
  imports = [
    ../../home
    ./home-vars.nix
  ];

  my.profile = "workstation";
  my.gui = "kde";

  home = {
    stateVersion = "22.11";
    packages = with pkgs; [
      # dev tools
      postgresql
    ];
  };

  programs.home-manager.enable = true;
}
