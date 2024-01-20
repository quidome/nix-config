{ config, pkgs, lib, ... }:
{
  imports = [
    ../../home
    ./home-vars.nix
  ];

  my.profile = "workstation";
  my.gui = "kde";

  home = {
    stateVersion = "23.11";
    packages = with pkgs; [
      # dev tools
      postgresql
      jetbrains.idea-community
      temurin-bin-21

      # some tools
      cointop
      discord
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
