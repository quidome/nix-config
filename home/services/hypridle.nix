{ config, lib, ... }:
let
  cfg = config.services.hypridle;
in
{
  config = lib.mkIf cfg.enable {
    services.hypridle = {
      settings =
        {
          general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            before_sleep_cmd = "loginctl lock-session";
            # ignore_dbus_inhibit = false;
            lock_cmd = "pidof || hyprlock";
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
    };
  };
}
