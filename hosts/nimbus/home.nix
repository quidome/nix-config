{ lib, pkgs, ... }:
with lib;
{
  imports = [
    ./shared.nix
    ./home-vars.nix
    ../../home
  ];

  home = {
    stateVersion = "24.05";
    packages = with pkgs; [
      # dev tools
      jetbrains.idea-community

      # games
      openttd
      zeroad
    ];
  };
}
