{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.programs.waybar;
  font = config.settings.terminalFont;
in {
  config = mkIf cfg.enable {
    home.packages = with pkgs; [libappindicator-gtk3];

    programs.waybar = {
      systemd.enable = true;
      settings = [
        {
          height = 34;
          modules-left = [
            "pulseaudio"
            "idle_inhibitor"
            "backlight"
            "hyprland/mode"
          ];
          modules-center = ["hyprland/workspaces"];
          modules-right = [
            "network"
            "cpu"
            "memory"
            "temperature"
            "battery"
            "tray"
            "clock"
          ];

          backlight = {
            format = "{percent}% {icon}";
            format-icons = ["" ""];
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
            format-icons = ["" "" "" "" ""];
          };

          clock = {
            tooltip = true;
            format = "{:%H:%M}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
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
            format-bluetooth-muted = "{icon} {format_source}";
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
              default = ["" "" ""];
            };
            on-click = "pavucontrol";
          };

          temperature = {
            critical-threshold = 80;
            format = "{temperatureC}°C ";
          };

          tray = {
            icon-size = 21;
            spacing = 10;
          };

          "hyprland/workspaces" = {
            # format = "{icon}";
            on-click = "activate";
            on-scroll-up = "hyprctl dispatch workspace e-1";
            on-scroll-down = "hyprctl dispatch workspace e+1";
            # format-icons = { active = ""; urgent = ""; default = ""; };
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
        @define-color blue #afcbff;

        * {
            border: none;
            border-radius: 0;
            font-family: ${font.name}, Source Code Pro, Helvetica, Arial, sans-serif;
            font-size: 13pt;
            min-height: 0;
        }

        window#waybar {
            background: transparent;
            color: @foreground;
        }
        .modules-left,
        .modules-right,
        .modules-center {
          border-radius: 16px;
          background: @background;
        }

        #workspaces button.active {
          color: @background;
          background: @foreground;
          border-radius: 16px;
        }

        #workspaces button.urgent {
          color: @background;
          background: @warning;
          border-radius: 16px;
        }

        #mode {
            color: white;
            background: @modebg;
            margin: 10px 0 0 0;
            border-radius: 6px;
        }

        #idle_inhibitor, #tray, #clock, #temperature, #battery, #network, #pulseaudio, #backlight, #mode, #cpu, #memory {
            padding: 0 10px;
        }

        #backlight {
          padding: 0 16px 0 10px;
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

        #pulseaudio.muted {
            color: @warning;
        }

        #clock {
            margin-right: 2px;
            color: @blue;
        }

      '';
    };
  };
}
