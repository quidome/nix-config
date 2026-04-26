{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
with lib; let
  cfg = config.programs.waybar;
  font = config.settings.terminalFont;
  isNiri = config.settings.gui == "niri";
  useNetworkManager = osConfig.networking.networkmanager.enable;

  sharedModules = {
    backlight = {
      format = "{icon}";
      format-icons = ["" ""];
      tooltip = true;
    };

    battery = {
      states = {
        warning = 20;
        critical = 10;
      };
      design-capacity = false;
      format = "{icon}";
      format-charging = "󰂄";
      format-plugged = "";
      format-icons = ["" "" "" "" ""];
      tooltip-format = "{capacity}% — {timeTo}";
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
        activated = "";
        deactivated = "";
      };
    };

    memory = {
      format = "{}% ";
    };

    network = {
      format-wifi = "";
      format-ethernet = "󱘖";
      format-linked = "󱘖";
      format-disconnected = "⚠";
      tooltip-format-wifi = "{essid} ({signalStrength}%)";
    };

    pulseaudio = {
      format = "{icon}";
      format-bluetooth = " {icon}";
      format-bluetooth-muted = " ";
      format-muted = "";
      format-source = "{volume}% ";
      format-source-muted = "";
      format-icons = {
        headphone = "";
        hands-free = "󰋎";
        headset = "󰋎";
        phone = "";
        portable = "";
        car = "";
        default = ["" "" ""];
      };
      tooltip-format = "{volume}% — {format_source}";
      on-click = "pavucontrol";
    };

    "custom/mic" = {
      exec = "${pkgs.pulseaudio}/bin/pactl get-source-mute @DEFAULT_SOURCE@ | grep -q yes && echo '{\"text\":\"\",\"class\":\"muted\"}' || echo '{\"text\":\"\",\"class\":\"active\"}'";
      return-type = "json";
      interval = 2;
      on-click = "${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      tooltip = false;
    };

    temperature = {
      critical-threshold = 80;
      format = "{temperatureC}°C ";
    };

    tray = {
      icon-size = 21;
      spacing = 10;
    };
  };

  niriConfig =
    sharedModules
    // {
      height = 34;
      modules-left = [
        "pulseaudio"
        "custom/mic"
        "idle_inhibitor"
        "backlight"
      ];
      modules-center = ["niri/workspaces"];
      modules-right =
        (optional (!useNetworkManager) "network")
        ++ [
          "cpu"
          "memory"
          "temperature"
          "battery"
          "tray"
          "clock"
        ];

      "niri/workspaces" = {
        on-click = "activate";
      };
    };

  hyprlandConfig =
    sharedModules
    // {
      height = 34;
      modules-left = [
        "pulseaudio"
        "custom/mic"
        "idle_inhibitor"
        "backlight"
        "hyprland/mode"
      ];
      modules-center = ["hyprland/workspaces"];
      modules-right =
        (optional (!useNetworkManager) "network")
        ++ [
          "cpu"
          "memory"
          "temperature"
          "battery"
          "tray"
          "clock"
        ];

      "hyprland/workspaces" = {
        on-click = "activate";
        on-scroll-up = "hyprctl dispatch workspace e-1";
        on-scroll-down = "hyprctl dispatch workspace e+1";
      };

      "hyprland/window" = {
        "separate-output" = true;
      };
    };
in {
  config = mkIf cfg.enable {
    home.packages = with pkgs; [libappindicator-gtk3];

    programs.waybar = {
      systemd.enable = mkDefault true;
      settings = [
        (
          if isNiri
          then niriConfig
          else hyprlandConfig
        )
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

        #idle_inhibitor, #tray, #clock, #temperature, #battery, #network, #pulseaudio, #custom-mic, #backlight, #mode, #cpu, #memory {
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

        #custom-mic.muted {
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
