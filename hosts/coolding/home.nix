{ pkgs, ... }:
let
  my-python-packages = ps: with ps; [
    pip
  ];
in
{
  imports = [
    ./home-vars.nix
    ./shared.nix
    ../../home
  ];

  home = {
    stateVersion = "24.05";
    packages = with pkgs; [
      # dev tools
      postgresql
      poetry
      (python3.withPackages my-python-packages)
      temurin-bin-21
      nodejs_20
      jetbrains.idea-community
#      rustup

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
}
