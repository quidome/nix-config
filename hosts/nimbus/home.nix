{ pkgs, ... }:
let
  my-python-packages = ps: with ps; [
    pip
  ];
in
{
  imports = [
    ./shared.nix
    ./home-vars.nix
    ../../home
  ];

  home = {
    stateVersion = "24.05";
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
    ];
  };
}
