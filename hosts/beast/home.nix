{ pkgs, ... }:
{
  imports = [
    ./shared.nix
    ../../home
    ./home-vars.nix
  ];

  config = {
    home.stateVersion = "23.11";
    home.packages = with pkgs; [
      # dev tools
      postgresql
    ];

    wayland.windowManager.hyprland.settings.monitor = [
      ",preferred,auto,auto"
      "DP-1, disable"
    ];
  };
}
