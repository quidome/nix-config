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
    # Checked with `niri validate` at build time.
    xdg.configFile."niri/config.kdl".source = pkgs.runCommand "niri-config.kdl" {} ''
      ${lib.getExe pkgs.niri} validate -c ${./config.kdl}
      cp ${./config.kdl} $out
    '';

    home.packages = with pkgs; [
      # Send notifications from scripts (notify-send).
      libnotify
      # Media keys; avizo handles volume and brightness keys with a pop-up.
      playerctl
    ];

    # Terminal and launcher used by the key bindings in config.kdl.
    programs = {
      alacritty.enable = lib.mkDefault true;
      fuzzel.enable = lib.mkDefault true;

      # Screen lock, also used by the Super+Alt+L key binding.
      swaylock = {
        enable = lib.mkDefault true;
        settings = {
          color = "000000";
          show-failed-attempts = true;
        };
      };
    };

    services = {
      # Volume and brightness pop-up, used by volumectl and lightctl.
      avizo.enable = lib.mkDefault true;

      # Notifications, started by D-Bus on the first notification.
      mako = {
        enable = lib.mkDefault true;
        settings = {
          default-timeout = 5000;
          # Keep critical notifications until they are dismissed.
          "urgency=critical".default-timeout = 0;
        };
      };

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
