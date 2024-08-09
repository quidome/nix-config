{ config, lib, ... }:
let
  cfg = config.programs.swaylock;
in
{
  programs.swaylock = lib.mkIf cfg.enable {
    settings = {
      image = "~/Pictures/Wallpapers/183940.jpg";
      scaling = "fill";

      ignore-empty-password = false;
      indicator-radius = 75;
      indicator-thickness = 14;
      line-uses-ring = true;

      # entry ring colors
      inside-color = "28282899";
      ring-color = "282828";
      key-hl-color = "a1a1a1";
    };
  };
}
