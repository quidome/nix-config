{
  config,
  lib,
}: let
  colors =
    if config.settings.theme == "light"
    then {
      base = "#eff1f5";
      text = "#4c4f69";
      surface2 = "#acb0be";
      accent = "#1e66f5";
      green = "#40a02b";
      peach = "#fe640b";
      red = "#d20f39";
    }
    else {
      base = "#1e1e2e";
      text = "#cdd6f4";
      surface2 = "#a6adc8";
      accent = "#89b4fa";
      green = "#a6e3a1";
      peach = "#fab387";
      red = "#f38ba8";
    };
in {
  enable = lib.mkDefault true;
  systemd = {
    enable = lib.mkDefault true;
    targets = ["hyprland-session.target"];
  };

  settings.mainBar = {
    layer = "top";
    position = "top";
    height = 32;
    spacing = 8;

    modules-left = ["hyprland/workspaces"];
    modules-center = ["clock"];
    modules-right = ["idle_inhibitor" "tray" "network" "pulseaudio" "battery"];

    "hyprland/workspaces" = {
      all-outputs = true;
      disable-scroll = true;
      format = "{icon}";
    };

    clock = {
      format = "{:%a %d %b  %H:%M}";
      format-alt = "{:%Y-%m-%d}";
      tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
    };

    idle_inhibitor = {
      format = "{icon}";
      format-icons = {
        activated = "";
        deactivated = "";
      };
    };

    network = {
      format-wifi = "  {essid}";
      format-ethernet = "󰈀  {ifname}";
      format-disconnected = "󰖪 offline";
      tooltip-format = "{ifname}: {ipaddr}/{cidr}";
    };

    pulseaudio = {
      format = "{icon} {volume}%";
      format-bluetooth = "{icon} {volume}%";
      format-muted = "󰝟 muted";
      format-icons.default = ["󰕿" "󰖀" "󰕾"];
      on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    };

    battery = {
      states = {
        warning = 20;
        critical = 10;
      };
      format = "{capacity}% {icon}";
      format-charging = "{capacity}% 󰂄";
      format-plugged = "{capacity}% ";
      format-alt = "{time} {icon}";
      format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
    };

    tray = {
      icon-size = 18;
      spacing = 10;
    };
  };

  style = ''
    * {
      border: none;
      border-radius: 0;
      font-family: "JetBrainsMono Nerd Font", sans-serif;
      font-size: 13px;
      min-height: 0;
    }

    window#waybar {
      background: transparent;
      color: ${colors.text};
    }

    .modules-left,
    .modules-center,
    .modules-right {
      background: ${colors.base};
      border-radius: 16px;
      margin: 4px 6px;
    }

    #workspaces button {
      color: ${colors.surface2};
      padding: 0 10px;
      border-radius: 16px;
    }

    #workspaces button.active {
      background: ${colors.text};
      color: ${colors.base};
    }

    #clock,
    #idle_inhibitor,
    #network,
    #pulseaudio,
    #battery,
    #tray {
      padding: 0 10px;
    }

    #clock {
      color: ${colors.accent};
    }

    #battery.charging,
    #battery.plugged {
      color: ${colors.green};
    }

    #idle_inhibitor.activated,
    #pulseaudio.muted,
    #battery.warning:not(.charging) {
      color: ${colors.peach};
    }

    #network.disconnected,
    #battery.critical:not(.charging) {
      color: ${colors.red};
    }
  '';
}
