{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.programs.waybar;
in
{
  options = with types; {
    settings.waybar.modules-left = mkOption {
      default = [ "sway/workspaces" "sway/mode" ];
      type = listOf str;
    };

    settings.waybar.modules-center = mkOption {
      default = null;
      type = nullOr (listOf str);
    };

  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      libappindicator-gtk3
      pavucontrol
    ];

    programs.waybar = {
      systemd.enable = true;

      settings = [
        {
          height = 34;
          modules-left = config.settings.waybar.modules-left;
          modules-center = config.settings.waybar.modules-center;
          modules-right = [
            "pulseaudio"
            "idle_inhibitor"
            "network"
            "cpu"
            "memory"
            "temperature"
            "backlight"
            "battery"
            "tray"
            "clock"
          ];

          backlight = {
            format = "{percent}% {icon}";
            format-icons = [ "" "" ];
          };

          battery = {
            states = {
              warning = 20;
              critical = 10;
            };
            design-capacity = false;
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            format-icons = [ "" "" "" "" "" ];
          };

          clock = {
            tooltip-format = "<big>{: %Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%Y-%m-%d}";
          };

          cpu = {
            format = "{usage}% ";
            tooltip = false;
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
          };

          memory = {
            format = "{}% ";
          };

          network = {
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ifname}: {ipaddr}/{cidr} 󱘖";
            format-linked = "{ifname} (No IP) 󱘖";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };

          pulseaudio = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "󰋎";
              headset = "󰋎";
              phone = "";
              portable = "";
              car = "";
              default = [ "" "" "" ];
            };
            on-click = " pavucontrol ";
          };


          temperature = {
            critical-threshold = 80;
            format = "{temperatureC}°C ";
          };

          tray = {
            icon-size = 21;
            spacing = 10;
          };

          "sway/workspaces" = {
            # all-outputs = true;
            format = "{icon}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "6" = "";
              "7" = "";
              "8" = "";
              "9" = "";
              "10" = "";
            };
          };

          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "6" = "";
              "7" = "";
              "8" = "";
              "9" = "";
              "10" = "";
            };
          };

          "hyprland/window" = {
            "separate-output" = true;
          };
        }
      ];
      style = ''
        @define-color foreground #a1a1a1; /* #aaaaaa; */
        @define-color background #282828; /* #24283b; */
        @define-color modebg @warning;
        @define-color border #ffffff;
        @define-color ok #34eb77;
        @define-color warning #ff832b;
        @define-color critical #ff2b2b;

        * {
            border: none;
            border-radius: 0;
            font-family: JetBrainsMono Nerd Font, Source Code Pro, Helvetica, Arial, sans-serif;
            font-size: 12pt;
            min-height: 0;
        }

        window#waybar {
            background: transparent;
            color: @foreground;
        }

        #workspaces {
            background: @background;
            margin: 2px 2px 0 2px;
            border-radius: 5px;
        }

        #workspaces button {
            padding: 0 10px 0 10px;
            color: @foreground;
        }

        #workspaces button.focused {
            color: @background;
            background: @foreground;
            border-radius: 5px;
        }

        #custom-vpn, #idle_inhibitor, #tray, #clock, #temperature, #battery, #network, #pulseaudio, #backlight, #mode, #cpu, #memory {
            background: @background;
            padding: 5px 10px;
            margin: 2px 0 0 0;
        }

        #mode {
            color: white;
            background: @modebg;
            margin: 2px 0 0 0;
            border-radius: 5px;
        }

        #battery.critical:not(.charging) {
            background: @critical;
            color: @foreground;
        }

        #battery.warning:not(.charging) {
            color: @warning;
        }
 
        #battery.charging {
            color: @ok;
        }

        #idle_inhibitor.activated {
            color: @warning;
        }

        #network.disconnected {
            color: @critical;
        }

        #custom-vpn.connected {
          color: @ok;
        }

        #pulseaudio {
            border-radius: 5px 0 0 5px;
        }

        #pulseaudio.muted {
            color: @warning;
        }

        #clock {
            margin-right: 2px;
            border-radius: 0 5px 5px 0;
        }

      '';
    };
  };
}
