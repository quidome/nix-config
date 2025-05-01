{ pkgs, ... }:
{
  imports = [
    ./shared.nix
    ../../home
    ./home-vars.nix
  ];

  config = {

    home = {
      stateVersion = "23.11";
      packages = with pkgs; [
        # dev tools
        postgresql
        jetbrains.idea-community
        temurin-bin-21
        ktlint

        # gaming
        openttd
        zeroad
      ];
    };

    wayland.windowManager.hyprland.settings.monitor = [
      ",preferred,auto,auto"
      "DP-1, disable"
    ];
  };
}
