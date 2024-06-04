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
        emacs
      ];
    };

    # Sway specific settings, to force single screen usage
    wayland.windowManager.sway.config.output = {
      DP-1 = {
        disable = "";
        bg = "#000000 solid_color";
      };
    };
    services.kanshi.enable = false;

  };
}
