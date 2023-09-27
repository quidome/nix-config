{ config, lib, ... }:
{
  config.programs.swaylock.settings = lib.mkIf config.programs.swaylock.enable {
    image = "~/Pictures/wallpapers/183940.jpg";
    scaling = "fill";

    ignore-empty-password = true;
    indicator-radius = 75;
    indicator-thickness = 14;
    line-uses-ring = true;

    # entry ring colors
    inside-color = "28282899";
    ring-color = "282828";
    key-hl-color = "a1a1a1";
  };
}
