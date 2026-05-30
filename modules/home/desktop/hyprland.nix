{
  config,
  lib,
  pkgs,
  ...
}: let
  terminal = config.settings.terminal;
in {
  config = lib.mkIf (config.settings.gui == "hyprland") {
    home.packages = [pkgs.wofi];

    wayland.windowManager.hyprland = {
      enable = lib.mkDefault true;
      settings = {
        "$mod" = "SUPER";
        "$terminal" = terminal;

        bind = [
          "$mod, Return, exec, $terminal"
          "$mod, D, exec, wofi --show drun"
        ];
      };
    };
  };
}
