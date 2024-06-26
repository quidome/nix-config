{ config, pkgs, lib, ... }:
with lib;
let
  swayEnabled = (config.my.gui == "sway");
  zshEnabled = config.programs.zsh.enable;
in
{
  config = mkIf swayEnabled {
    my.programs.wofi.enable = true;
    my.xdg.enable = true;

    home.sessionVariables = {
      XDG_CURRENT_DESKTOP = "sway";
    };

    # extra packages for my sway config
    home.packages = with pkgs; [
      swayidle
      wl-clipboard

      brightnessctl
      grim
      imv
      pamixer
      playerctl
      slurp
      wdisplays
      xorg.xeyes
      xorg.xlsclients

      # theming
      gtk-engine-murrine
      gtk_engines
      gsettings-desktop-schemas
    ];

    gtk = {
      enable = true;
      font.name = "Noto Sans";
      theme.name = "Adwaita";
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

    programs.alacritty.enable = true;

    programs.swaylock = {
      enable = true;
      settings = {
        image = "~/Pictures/Wallpapers/183940.jpg";
        scaling = "fill";

        ignore-empty-password = true;
        indicator-radius = 75;
        indicator-thickness = 14;
        line-uses-ring = true;

        # entry ring colors
        inside-color = "28282899";
        ring-color = "282828";
        key-hl-color = "a1a1a1";
      };
    };

    programs.waybar.enable = true;

    programs.zsh.initExtraFirst = mkIf zshEnabled ''
      if [ -z "''${DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ] ; then
        # run sway, logout upon exit
        exec sway > ''${HOME}/.local/log/sway.log
      fi
    '';

    services = {
      kanshi = {
        enable = mkDefault true;
        systemdTarget = "graphical-session.target";
      };

      mako = {
        enable = true;
        anchor = "bottom-right";
        defaultTimeout = 10000;

        font = "JetBrainsMono Nerd Font 11";

        borderRadius = 5;
        backgroundColor = "#282828ff";
        borderColor = "#161616ff";
        textColor = "#a1a1a1";

        margin = "2,2";

        groupBy = "summary";
        extraConfig = ''
          [grouped]
          format=<b>%s</b>\n%b
        '';
      };
    };

    xdg.systemDirs.data = [
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    ];

    # enable dbus service for sway
    systemd.user.sockets.dbus = {
      Unit = {
        Description = "D-Bus User Message Bus Socket";
      };
      Socket = {
        ListenStream = "%t/bus";
        ExecStartPost = "${pkgs.systemd}/bin/systemctl --user set-environment DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus";
      };
      Install = {
        WantedBy = [ "sockets.target" ];
        Also = [ "dbus.service" ];
      };
    };

    systemd.user.services.dbus = {
      Unit = {
        Description = "D-Bus User Message Bus";
        Requires = [ "dbus.socket" ];
      };
      Service = {
        ExecStart = "${pkgs.dbus}/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation";
        ExecReload = "${pkgs.dbus}/bin/dbus-send --print-reply --session --type=method_call --dest=org.freedesktop.DBus / org.freedesktop.DBus.ReloadConfig";
      };
      Install = {
        Also = [ "dbus.socket" ];
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      checkConfig = false;

      config = {
        bars = [ ];

        defaultWorkspace = "workspace number 1";

        floating = {
          border = 0;
          criteria = [
            { class = "^Pinentry$"; }
            { app_id = "pavucontrol"; }
            { app_id = "^firefox$"; title = "^Extension:"; }
            { app_id = "^firefox$"; title = "^Library$"; }
          ];
        };

        fonts = {
          names = [ "JetBrainsMono Nerd Font" ];
          size = 10.0;
        };

        gaps = {
          inner = 2;
          outer = 0;
        };

        input = {
          "1133:49242:Logitech_USB_Optical_Mouse" = { left_handed = "enabled"; };
          "type:keyboard" = { xkb_options = "caps:none"; };
          "type:mouse" = { natural_scroll = "enabled"; };
          "type:pointer" = { natural_scroll = "enabled"; };
          "type:tablet_tool" = { tool_mode = "* relative"; };
          "type:touchpad" = { natural_scroll = "enabled"; tap = "enabled"; };
        };

        keybindings =
          let
            modifier = config.wayland.windowManager.sway.config.modifier;
          in
          mkOptionDefault {
            "${modifier}+Ctrl+Right" = "workspace next";
            "${modifier}+Ctrl+Left" = "workspace prev";

            "${modifier}+Ctrl+Shift+Up" = "move workspace to output up";
            "${modifier}+Ctrl+Shift+Down" = "move workspace to output down";
            "${modifier}+Ctrl+Shift+Left" = "move workspace to output left";
            "${modifier}+Ctrl+Shift+Right" = "move workspace to output right";

            "${modifier}+0" = "workspace number 10";
            "${modifier}+Shift+0" = "move container to workspace number 10";

            "Print" = "exec IMG=~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%s).png && grim -g \"\$(slurp)\" $IMG && wl-copy -t image/png < $IMG";
            "Shift+Print" = "exec IMG=~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%s).png && grim $IMG && wl-copy -t image/png < $IMG";
            "XF86Eject" = "exec IMG=~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%s).png && grim -g \"\$(slurp)\" $IMG && wl-copy -t image/png < $IMG";
            "Shift+XF86Eject" = "exec IMG=~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%s).png && grim $IMG && wl-copy -t image/png < $IMG";

            "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
            "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";

            "XF86AudioPlay" = "exec playerctl play-pause";
            "Shift+XF86AudioMute" = "exec playerctl play-pause";
            "XF86AudioNext" = "exec playerctl next";
            "Shift+XF86AudioRaiseVolume" = "exec playerctl next";
            "XF86AudioPrev" = "exec playerctl previous";
            "Shift+XF86AudioLowerVolume" = "exec playerctl previous";
            "XF86AudioMute" = "exec pamixer -t";
            "XF86AudioMicMute" = "exec amixer set Capture toggle -q";
            "XF86AudioLowerVolume" = "exec pamixer -d 2";
            "XF86AudioRaiseVolume" = "exec pamixer -i 3";

            "Control+Space" = "exec makoctl dismiss --group";

            "${modifier}+Shift+backslash" = "move scratchpad";
            "${modifier}+backslash" = "scratchpad show";

            "${modifier}+Shift+e" = "mode power";

            "${modifier}+p" = "exec wofi --show drun | xargs swaymsg exec --";
            "${modifier}+Shift+b" = "exec browser-chooser";
            "${modifier}+Shift+p" = "exec ~/bin/rofipass";
            "${modifier}+m" = "exec alacritty -e ncspot";
            "${modifier}+n" = "exec alacritty -e ranger";
            "${modifier}+t" = "exec alacritty -e btm";
          };

        modes = {
          power = {
            "p" = "exec systemctl poweroff, mode default";
            "r" = "exec systemctl reboot, mode default";
            "k" = "exec swaymsg exit, mode default";
            "l" = "exec swaylock -f, mode default";
            "s" = "exec systemctl suspend, mode default";
            "Escape" = "mode default";
          };

          resize = {
            "Left" = "resize shrink width 10px";
            "Down" = "resize grow height 10px";
            "Up" = "resize shrink height 10px";
            "Right" = "resize grow width 10px";

            "Return" = "mode default";
            "Escape" = "mode default";
          };
        };

        modifier = "Mod4";
        output."*".bg = "~/.config/wallpaper fill";
        menu = "wofi --show run | xargs swaymsg exec --";

        startup =
          let
            lock = "swaylock -f";
          in
          [
            { command = "systemctl --user restart kanshi.service"; always = true; }
            { command = "~/bin/import-gsettings"; }
            { command = "NO_TMUX=1 alacritty --class alacritty_sp"; }
            {
              command = ''
                swayidle -w \
                  timeout 300 '${lock}' \
                  timeout 600 'swaymsg "output * dpms off"' \
                  resume 'swaymsg "output * dpms on"' \
                  before-sleep '${lock}'
              '';
            }
          ];

        terminal = "alacritty";

        window = {
          border = 0;
          hideEdgeBorders = "both";
          titlebar = false;

          commands = [
            {
              criteria = { app_id = "^alacritty_sp$"; };
              command = "move scratchpad";
            }
          ];
        };

      };

      extraSessionCommands = ''
        # make java apps work with tiling
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
    };
  };
}
