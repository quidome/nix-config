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

  cursor = config.home.pointerCursor;
  c = import ../../theme/palette.nix config.settings.theme;
  themeKdl = pkgs.writeText "theme.kdl" ''
    cursor {
        xcursor-theme "${cursor.name}"
        xcursor-size ${toString cursor.size}
    }
    layout {
        focus-ring {
            active-color "#${c.accent}"
            inactive-color "#${c.surface1}"
        }
        border {
            active-color "#${c.accent}"
            inactive-color "#${c.surface1}"
            urgent-color "#${c.red}"
        }
    }
  '';
  niriConfig = pkgs.runCommand "niri-config" {} ''
    mkdir $out
    cp ${./config.kdl} $out/config.kdl
    cp ${themeKdl} $out/theme.kdl
    ${lib.getExe pkgs.niri} validate -c $out/config.kdl
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
    # config.kdl includes the generated theme.kdl; both are checked
    # with `niri validate` at build time.
    xdg.configFile = {
      "niri/config.kdl".source = "${niriConfig}/config.kdl";
      "niri/theme.kdl".source = "${niriConfig}/theme.kdl";
    };

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
      # Colors are set in the theme module.
      swaylock = {
        enable = lib.mkDefault true;
        settings.show-failed-attempts = true;
      };

      # Status bar, started with graphical-session.target.
      waybar = {
        enable = lib.mkDefault true;
        systemd.enable = lib.mkDefault true;
        settings.main = {
          layer = "top";
          position = "top";
          modules-center = ["clock"];
          modules-right =
            ["privacy" "idle_inhibitor" "tray" "wireplumber" "network" "bluetooth"]
            ++ lib.optionals isLaptop ["power-profiles-daemon" "battery"];

          clock.format = "{:%a %d %b  %H:%M}";
          # Stops screen lock and suspend while activated.
          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "AWAKE";
              deactivated = "auto";
            };
          };
          wireplumber = {
            format = "VOL {volume}%";
            format-muted = "VOL muted";
            on-click = lib.getExe pkgs.pavucontrol;
            on-click-right = "${lib.getExe' config.services.avizo.package "volumectl"} toggle-mute";
          };
          network = {
            format-wifi = "{essid} {signalStrength}%";
            format-ethernet = "wired";
            format-disconnected = "offline";
            on-click = "${lib.getExe config.programs.alacritty.package} -e ${lib.getExe' pkgs.networkmanager "nmtui"}";
          };
          bluetooth = {
            format = "BT {status}";
            format-connected = "BT {device_alias}";
          };
          # Click to change to the next power profile.
          power-profiles-daemon.format = "{profile}";
          battery = {
            format = "BAT {capacity}%";
            format-charging = "CHG {capacity}%";
            states = {
              warning = 20;
              critical = 10;
            };
          };
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
