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

  my.gui = "sway";

  home = {
    stateVersion = "22.11";
    packages = with pkgs; [
      android-tools
      wireguard-tools
      httpie
      ipcalc

      # dev tools
      jetbrains.idea-community
      poetry
      postgresql
      temurin-bin-21
      (python3.withPackages my-python-packages)

      # other tools
      blender
    ];
  };
}
