{ pkgs, ... }:
let
  my-python-packages = ps: with ps; [
    pip
  ];
in
{
  imports = [
    ../../home
    ./home-vars.nix
  ];

  my.profile = "workstation";
  my.gui = "gnome";

  home = {
    stateVersion = "22.11";
    packages = with pkgs; [
      wireguard-tools
      httpie
      ipcalc
      # dev tools
      jetbrains.idea-community
      poetry
      postgresql
      temurin-bin-21
      (python3.withPackages my-python-packages)

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
}
