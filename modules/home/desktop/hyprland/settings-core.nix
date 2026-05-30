{
  "debug:disable_scale_checks" = true;
  ecosystem.no_update_news = true;

  "$mod" = "SUPER";
  "$launcher" = "uwsm app --";
  "$terminal" = "foot";

  env = [
    "XCURSOR_SIZE,24"
    "HYPRCURSOR_SIZE,24"
  ];

  animations.enabled = false;

  general = {
    gaps_in = 5;
    gaps_out = 5;

    border_size = 2;
    "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
    "col.inactive_border" = "rgba(595959aa)";

    resize_on_border = true;
    allow_tearing = false;
    layout = "dwindle";
  };

  decoration = {
    rounding = 3;

    active_opacity = 1.0;
    inactive_opacity = 1.0;

    blur = {
      enabled = true;
      size = 3;
      passes = 1;
      vibrancy = 0.1696;
    };
  };

  dwindle = {
    pseudotile = true;
    preserve_split = true;
  };

  master = {
    new_status = "master";
  };

  monitor = [
    ", preferred, auto-left, 1"
  ];

  misc = {
    force_default_wallpaper = 2;
    disable_hyprland_logo = false;
  };
}
