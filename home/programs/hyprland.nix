{ config, lib, pkgs, ... }:
with lib;
let
  hyprlandEnabled = (config.settings.gui == "hyprland");
in
{
  config = mkIf hyprlandEnabled {
    home.packages = with pkgs; [ playerctl ];

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
      alacritty.enable = mkDefault true;
      hyprlock.enable = mkDefault true;
      kitty.enable = mkDefault false;
      waybar.enable = mkDefault true;
      wofi.enable = mkDefault true;
    };

    settings.waybar.modules-left = mkDefault [ "hyprland/workspaces" "hyprland/mode" ];

    services = {
      avizo.enable = mkDefault true;
      hypridle.enable = mkDefault true;
      kanshi.enable = mkDefault true;
      mako.enable = mkDefault true;
    };

    xdg.systemDirs.data = [
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    ];

    wayland.windowManager.hyprland.enable = mkDefault true;
    wayland.windowManager.hyprland.settings = {
      "$mod" = "SUPER";

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
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
        force_default_wallpaper = -1;
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
        "$mod, Return, exec, uwsm app -- alacritty"
        "$mod, Space, exec, uwsm app -- $(wofi --show drun --define=drun-print_desktop_file=true)"
        "$mod, C, killactive,"
        "$mod SHIFT, Q, exit,"
        "$mod, E, exec, uwsm app -- thunar"
        "$mod, V, togglefloating,"
        "$mod, D, exec, uwsm app -- $(wofi --show run --define=drun-print_desktop_file=true)"
        "$mod, P, pseudo, # dwindle"
        "$mod, J, togglesplit, # dwindle"
        "$mod, L, exec, hyprlock"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"


        ", XF86AudioRaiseVolume, exec, volumectl -u up"
        ", XF86AudioLowerVolume, exec, volumectl -u down"
        ", XF86AudioMute, exec, volumectl toggle-mute"
        ", XF86AudioPlay, exec, playerctl play-pause"

        ", XF86MonBrightnessDown, exec, lightctl down"
        ", XF86MonBrightnessUp, exec, lightctl up"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "float, class:org.pulseaudio.pavucontrol"
      ];
    };

  };
}
