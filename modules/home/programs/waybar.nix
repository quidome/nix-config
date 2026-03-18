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
      systemd.enable = mkDefault true;
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
        /* Catppuccin colors are injected via catppuccin module */

        * {
            border: none;
            border-radius: 0;
            font-family: ${font.name}, Source Code Pro, Helvetica, Arial, sans-serif;
            font-size: 13pt;
            min-height: 0;
        }

        window#waybar {
            background: transparent;
            color: @text;
        }
        .modules-left,
        .modules-right,
        .modules-center {
          border-radius: 16px;
          background: @base;
        }

        #workspaces button.active {
          color: @base;
          background: @text;
          border-radius: 16px;
        }

        #workspaces button.urgent {
          color: @base;
          background: @peach;
          border-radius: 16px;
        }

        #mode {
            color: @base;
            background: @peach;
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
            background: @red;
            color: @base;
        }

        #battery.warning:not(.charging) {
            color: @peach;
        }

        #battery.charging {
            color: @green;
        }

        #idle_inhibitor.activated {
            color: @peach;
        }

        #network.disconnected {
            color: @red;
        }

        #custom-vpn.connected {
          color: @green;
        }

        #pulseaudio.muted {
            color: @peach;
        }

        #clock {
            margin-right: 2px;
            color: @blue;
        }

      '';
    };
  };
}
