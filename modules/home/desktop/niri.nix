{
  config,
  lib,
  pkgs,
  ...
}: let
  isLaptop = config.settings.formFactor == "laptop";
  systemctl = lib.getExe' pkgs.systemd "systemctl";

  # Lock the screen, unless it is already locked.
  lock = pkgs.writeShellScript "lock" ''
    ${lib.getExe' pkgs.procps "pgrep"} -x swaylock || ${lib.getExe config.programs.swaylock.package} -f
  '';

  # Exit 0 when a charger (mains or USB-C) is connected.
  onAc = pkgs.writeShellScript "on-ac" ''
    for supply in /sys/class/power_supply/*; do
      case "$(cat "$supply/type")" in
        Mains | USB) [ "$(cat "$supply/online" 2>/dev/null)" = 1 ] && exit 0 ;;
      esac
    done
    exit 1
  '';
in {
  config = lib.mkIf (config.settings.gui == "niri") {
    # Terminal and launcher used by niri's default key bindings.
    programs = {
      alacritty.enable = lib.mkDefault true;
      fuzzel.enable = lib.mkDefault true;

      # Screen lock, also used by niri's default Super+Alt+L key binding.
      swaylock = {
        enable = lib.mkDefault true;
        settings = {
          color = "000000";
          show-failed-attempts = true;
        };
      };
    };

    services = {
      # Password prompt for polkit, started with graphical-session.target.
      polkit-gnome.enable = lib.mkDefault true;

      swayidle = {
        enable = lib.mkDefault true;
        timeouts =
          [
            {
              timeout = 300;
              command = "${lock}";
            }
            {
              timeout = 330;
              command = "${lib.getExe pkgs.niri} msg action power-off-monitors";
            }
          ]
          # Suspend laptops after 15 minutes on battery, 30 minutes on AC.
          ++ lib.optionals isLaptop [
            {
              timeout = 900;
              command = "${onAc} || ${systemctl} suspend";
            }
            {
              timeout = 1800;
              command = "${onAc} && ${systemctl} suspend";
            }
          ];
        events = {
          before-sleep = "${lock}";
          lock = "${lock}";
        };
      };
    };
  };
}
