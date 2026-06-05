{lib}: {
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
      background: alpha(@base, 0.72);
      color: @text;
    }

    #workspaces button {
      color: @surface2;
      padding: 0 10px;
    }

    #workspaces button.active {
      color: @accent;
    }

    #clock,
    #idle_inhibitor,
    #network,
    #pulseaudio,
    #battery,
    #tray {
      padding: 0 10px;
    }

    #idle_inhibitor.activated,
    #pulseaudio.muted,
    #battery.warning:not(.charging) {
      color: @peach;
    }

    #network.disconnected,
    #battery.critical:not(.charging) {
      color: @red;
    }
  '';
}
