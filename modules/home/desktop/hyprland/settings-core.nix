{terminal ? "foot"}: {
  mod = {_var = "SUPER";};
  launcher = {_var = "uwsm app --";};
  terminal = {_var = terminal;};

  config = {
    debug.disable_scale_checks = true;
    ecosystem.no_update_news = true;

    env = [
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"
    ];

    animations = {
      enabled = true;
      animation = [
        "windows, 1, 3, default"
        "windowsIn, 1, 3, default, popin 80%"
        "windowsOut, 1, 3, default, popin 80%"
        "fade, 1, 3, default"
        "workspaces, 1, 3, default"
      ];
    };

    general = {
      gaps_in = 2;
      gaps_out = 3;

      border_size = 2;
      "col.active_border" = "rgba(33ccffee)";
      "col.inactive_border" = "rgba(595959aa)";

      resize_on_border = true;
      allow_tearing = false;
      layout = "scrolling";
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
      preserve_split = true;
    };

    master = {
      new_status = "master";
    };

    scrolling = {
      column_width = 0.5;
      fullscreen_on_one_column = true;
      follow_focus = true;
    };

    monitor = [
      ", preferred, auto-left, 1"
    ];

    misc = {
      force_default_wallpaper = 2;
      disable_hyprland_logo = false;
      disable_scale_notification = true;
    };

    binds.window_direction_monitor_fallback = true;
  };
}
