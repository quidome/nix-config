{ config, pkgs, lib, ... }:
{
  imports = [
    ../../home
    ./home-vars.nix
  ];

  my.profile = "workstation";

  home = {
    stateVersion = "22.11";
    packages = with pkgs; [
      # dev tools
      postgresql

      # 
      blender

      # office
      libreoffice-qt
      hunspell
      hunspellDicts.nl_NL
      hunspellDicts.en_US-large
      hunspellDicts.en_GB-large
    ];
  };

  programs.home-manager.enable = true;
}
