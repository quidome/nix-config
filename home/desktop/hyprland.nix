{ config, lib, pkgs, ... }:
with lib;
let
  hyprlandEnabled = (config.settings.gui == "hyprland");
  terminal = "kitty";
in
{
  config = mkIf hyprlandEnabled {
    home.packages = with pkgs; [
      imv
      grimblast
      playerctl
      pyprland
      wev
    ];

    xdg.mimeApps.enable = true;

    gtk = {
      enable = true;
      font.name = "Noto Sans";
      theme.name = "Adwaita";
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

    programs = {
      alacritty.enable = mkDefault (terminal == "alacritty");
      kitty.enable = mkDefault (terminal == "kitty");
      hyprlock.enable = mkDefault true;
      waybar.enable = mkDefault true;
      wofi.enable = mkDefault true;
    };

    services = {
      avizo.enable = mkDefault true;
      hypridle.enable = mkDefault true;
      kanshi.enable = mkDefault true;
      mako.enable = mkDefault true;
    };

    xdg.configFile."hypr/pyprland.json".text = builtins.toJSON {
      pyprland.plugins = [ "scratchpads" ];
      scratchpads.term = {
        command = "NO_TMUX=1 uwsm app -- ${terminal} --class scratchpad";
        margin = 50;
      };
    };

    xdg.systemDirs.data = [
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    ];



    wayland.windowManager.hyprland.enable = mkDefault true;
    wayland.windowManager.hyprland.settings = {
      "$mod" = "SUPER";
      "$launcher" = "uwsm app --";
      "$terminal" = terminal;

      "$scratchpad" = "class:^(scratchpad)$";
      "$scratchpadsize" = "size 50% 50%";

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      exec-once = [
        "$launcher pypr"
      ];

      animations.enabled = false;

      general = {
        gaps_in = 5;
        gaps_out = 5;

        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 3;

        active_opacity = 1.0;
        inactive_opacity = 1.0;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;

          vibrancy = 0.1696;
        };
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = 2;
        disable_hyprland_logo = false;
      };

      input =
        {
          kb_layout = "us";

          follow_mouse = 1;
          natural_scroll = true;
          left_handed = true;

          sensitivity = 0;

          touchpad.natural_scroll = true;
        };

      gestures.workspace_swipe = false;

      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      bind = [
        "$mod, Space, exec, $launcher $(wofi --show drun --define=drun-print_desktop_file=true)"
        "$mod, D, exec, $launcher $(wofi --show run --define=drun-print_desktop_file=true)"

        "$mod, Return, exec, $launcher $terminal"
        "$mod, E, exec, $launcher thunar"

        "$mod, P, pseudo, # dwindle"
        "$mod, J, togglesplit, # dwindle"

        "$mod, L, exec, hyprlock"
        "$mod, V, togglefloating,"
        "$mod, F, fullscreen"
        "SHIFT $mod, C, exit,"
        "SHIFT $mod, Q, killactive,"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        "CTRL $mod, left, workspace, r-1"
        "CTRL $mod, right, workspace, r+1"

        "$mod, S, togglespecialworkspace, magic"
        "SHIFT $mod, S, movetoworkspace, special:magic"

        "$mod, backslash, exec, pypr toggle term && hyprctl dispatch bringactivetotop"

        ", XF86AudioPlay, exec, playerctl play-pause"

        ", Print, exec, grimblast copysave area"
        "SHIFT, Print, exec, grimblast copysave active"
        "SHIFT CTRL, Print, exec, grimblast copysave output"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList
          (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9)
      );

      bindl = [
        ", XF86AudioMute, exec, volumectl toggle-mute"
      ];

      bindle = [
        ", XF86AudioRaiseVolume, exec, volumectl -u up"
        ", XF86AudioLowerVolume, exec, volumectl -u down"

        ", XF86MonBrightnessDown, exec, lightctl down"
        ", XF86MonBrightnessUp, exec, lightctl up"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "float, class:org.pulseaudio.pavucontrol"

        "float, $scratchpad"
        "$scratchpadsize, $scratchpad"
        "workspace special silent, $scratchpad"
        "center, $scratchpad"
      ];
    };

  };
}
