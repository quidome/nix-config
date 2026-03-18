{
  config,
  lib,
  ...
}: let
  cfg = config.programs.hyprlock;
in {
  config = lib.mkIf cfg.enable {
    programs.hyprlock = {
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 5;
          hide_cursor = true;
          no_fade_in = false;
        };

        background = [
          {
            path = "$HOME/Pictures/Wallpapers/183940.png";
          }
        ];

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            outline_thickness = 5;
            placeholder_text = "Password...";
            shadow_passes = 2;
          }
        ];
      };
    };
  };
}
