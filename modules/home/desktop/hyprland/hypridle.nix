{lib}: {
  enable = lib.mkDefault true;
  systemdTarget = lib.mkDefault "hyprland-session.target";

  settings = {
    general = {
      after_sleep_cmd = "hyprctl dispatch dpms on";
      before_sleep_cmd = "loginctl lock-session";
      lock_cmd = "pidof hyprlock || hyprlock";
    };

    listener = [
      {
        timeout = 600;
        on-timeout = "loginctl lock-session";
      }
      {
        timeout = 1200;
        on-timeout = "hyprctl dispatch dpms off";
        on-resume = "hyprctl dispatch dpms on";
      }
    ];
  };
}
