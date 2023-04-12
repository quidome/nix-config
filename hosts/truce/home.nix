{ config, pkgs, lib, ... }:
{
  imports = [
    ../../home
    ../../home/vscode.nix
    ../../home/profile/workstation.nix
    ./vars.nix
  ];

  home = {
    stateVersion = "22.11";
    packages = with pkgs; [
      # dev tools
      postgresql
    ];
  };

  programs.home-manager.enable = true;
  programs.firefox.enable = true;
}
