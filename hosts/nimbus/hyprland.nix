{
  wayland.windowManager.hyprland.settings = {
    #############################
    ### ENVIRONMENT VARIABLES ###
    #############################

    # See https://wiki.hyprland.org/Configuring/Environment-variables/
    env = [
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"
    ];

    #####################
    ### LOOK AND FEEL ###
    #####################

    # Refer to https://wiki.hyprland.org/Configuring/Variables/
    # https://wiki.hyprland.org/Configuring/Variables/#general
    general = {
      gaps_in = 5;
      gaps_out = 5;

      border_size = 2;

      # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = "rgba(595959aa)";

      # Set to true enable resizing windows by clicking and dragging on borders and gaps
      resize_on_border = true;

      # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
      allow_tearing = false;

      layout = "dwindle";
    };

    # https://wiki.hyprland.org/Configuring/Variables/#decoration
    decoration = {
      rounding = 3;

      # Change transparency of focused and unfocused windows
      active_opacity = 1.0;
      inactive_opacity = 1.0;

      # drop_shadow = true
      # shadow_range = 4
      # shadow_render_power = 3
      # col.shadow = rgba(1a1a1aee)

      # https://wiki.hyprland.org/Configuring/Variables/#blur
      blur = {
        enabled = true;
        size = 3;
        passes = 1;

        vibrancy = 0.1696;
      };
    };

    animations.enabled = false;

    # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    dwindle = {
      pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
      preserve_split = true; # You probably want this
    };

    # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    master = {
      new_status = "master";
    };

    # https://wiki.hyprland.org/Configuring/Variables/#misc
    misc = {
      force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
      disable_hyprland_logo = false; # If true disables the random hyprland logo / anime girl background. :(
    };

    #############
    ### INPUT ###
    #############

    # https://wiki.hyprland.org/Configuring/Variables/#input
    input =
      {
        kb_layout = "us";
        #kb_variant =
        #kb_model =
        #kb_options =
        #kb_rules =

        follow_mouse = 1;
        natural_scroll = true;
        left_handed = true;

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

        touchpad.natural_scroll = true;
      };

    # https://wiki.hyprland.org/Configuring/Variables/#gestures
    gestures.workspace_swipe = false;

    # Example per-device config
    # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
    device = {
      name = "epic-mouse-v1";
      sensitivity = -0.5;
    };

    ####################
    ### KEYBINDINGSS ###
    ####################

    # See https://wiki.hyprland.org/Configuring/Keywords/
    "$mod" = "SUPER"; # Sets "Windows" key as main modifier

    bind = [
      # Binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
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


      # Move focus with mainMod + arrow keys
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"

      # Switch workspaces with mainMod + [0-9]
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

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
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

      # Example special workspace (scratchpad)
      "$mod, S, togglespecialworkspace, magic"
      "$mod SHIFT, S, movetoworkspace, special:magic"

      # Scroll through existing workspaces with mod + scroll
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"


      # Multimedia keys
      ", XF86AudioRaiseVolume, exec, volumectl -u up"
      ", XF86AudioLowerVolume, exec, volumectl -u down"
      ", XF86AudioMute, exec, volumectl toggle-mute"
      ", XF86AudioPlay, exec, playerctl play-pause"

      # Brightness keys
      ", XF86MonBrightnessDown, exec, lightctl down"
      ", XF86MonBrightnessUp, exec, lightctl up"
    ];

    bindm = [
      # Move/resize windows with mod + LMB/RMB and dragging
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    ##############################
    ### WINDOWS AND WORKSPACES ###
    ##############################

    # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
    # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

    # Example windowrule v1
    # windowrule = float, ^(kitty)$

    # Example windowrule v2
    # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$

    windowrulev2 = [
      "suppressevent maximize, class:.*" # You'll probably like this.
      "float, class:org.pulseaudio.pavucontrol"
    ];
  }; # end of settings
}
