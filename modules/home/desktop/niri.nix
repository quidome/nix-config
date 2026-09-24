{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  isNiri = config.settings.gui == "niri";
  isLightTheme = config.settings.theme == "light";
  noctalia = lib.getExe pkgsUnstable.noctalia;
  gtkColorScheme =
    if isLightTheme
    then "prefer-light"
    else "prefer-dark";
  gtkTheme =
    if isLightTheme
    then "Adwaita"
    else "Adwaita Dark";
  qtStyle =
    if isLightTheme
    then "adwaita"
    else "adwaita-dark";

  rawConfig = pkgs.writeText "niri-config.kdl" ''
    environment {
      ELECTRON_OZONE_PLATFORM_HINT "auto"
    }

    input {
      keyboard {
        repeat-rate 35
        repeat-delay 200
        xkb {}
      }

      touchpad {
        tap
        natural-scroll
      }

      mouse {
        natural-scroll
      }

      trackpoint {
        natural-scroll
      }

      focus-follows-mouse max-scroll-amount="0%"
    }

    layout {
      gaps 5
      center-focused-column "never"

      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
      }

      default-column-width { proportion 0.5; }

      focus-ring {
        width 1.5
        active-color "#7fc8ff"
        inactive-color "#505050"
      }

      border {
        off
      }
    }

    spawn-at-startup "xwayland-satellite"

    hotkey-overlay {
      skip-at-startup
    }

    gestures {
      hot-corners {
        off
      }
    }

    prefer-no-csd
    screenshot-path "~/Pictures/Screenshots/screenshot-%Y-%m-%d_%H-%M-%S.png"

    animations {}

    window-rule {
      match app-id=r#"firefox$"# title="^Picture-in-Picture$"
      open-floating true
    }

    binds {
      Mod+Shift+Slash { show-hotkey-overlay; }

      Mod+Return hotkey-overlay-title="Open ghostty" { spawn "ghostty"; }
      Mod+D hotkey-overlay-title="Run an Application" { spawn "${noctalia}" "msg" "panel-toggle" "launcher"; }
      Mod+O repeat=false { toggle-overview; }
      Mod+Q repeat=false { close-window; }

      XF86AudioRaiseVolume allow-when-locked=true { spawn "${noctalia}" "msg" "volume-up"; }
      XF86AudioLowerVolume allow-when-locked=true { spawn "${noctalia}" "msg" "volume-down"; }
      XF86AudioMute allow-when-locked=true { spawn "${noctalia}" "msg" "volume-mute"; }
      XF86MonBrightnessUp allow-when-locked=true { spawn "${noctalia}" "msg" "brightness-up"; }
      XF86MonBrightnessDown allow-when-locked=true { spawn "${noctalia}" "msg" "brightness-down"; }
      XF86AudioPlay allow-when-locked=true { spawn "playerctl" "play-pause"; }
      XF86AudioStop allow-when-locked=true { spawn "playerctl" "stop"; }
      XF86AudioPrev allow-when-locked=true { spawn "playerctl" "previous"; }
      XF86AudioNext allow-when-locked=true { spawn "playerctl" "next"; }

      Mod+Left  { focus-column-left; }
      Mod+Down  { focus-window-down; }
      Mod+Up    { focus-window-up; }
      Mod+Right { focus-column-right; }
      Mod+H     { focus-column-left; }
      Mod+J     { focus-window-down; }
      Mod+K     { focus-window-up; }
      Mod+L     { focus-column-right; }

      Mod+Ctrl+Left  { move-column-left; }
      Mod+Ctrl+Down  { move-window-down; }
      Mod+Ctrl+Up    { move-window-up; }
      Mod+Ctrl+Right { move-column-right; }
      Mod+Ctrl+H     { move-column-left; }
      Mod+Ctrl+J     { move-window-down; }
      Mod+Ctrl+K     { move-window-up; }
      Mod+Ctrl+L     { move-column-right; }

      Mod+Page_Down { focus-workspace-down; }
      Mod+Page_Up   { focus-workspace-up; }
      Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
      Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }

      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }
      Mod+Ctrl+1 { move-column-to-workspace 1; }
      Mod+Ctrl+2 { move-column-to-workspace 2; }
      Mod+Ctrl+3 { move-column-to-workspace 3; }
      Mod+Ctrl+4 { move-column-to-workspace 4; }
      Mod+Ctrl+5 { move-column-to-workspace 5; }
      Mod+Ctrl+6 { move-column-to-workspace 6; }
      Mod+Ctrl+7 { move-column-to-workspace 7; }
      Mod+Ctrl+8 { move-column-to-workspace 8; }
      Mod+Ctrl+9 { move-column-to-workspace 9; }

      Mod+R { switch-preset-column-width; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+V { toggle-window-floating; }
      Mod+C { center-column; }

      Print { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print { screenshot-window; }

      Mod+Alt+L hotkey-overlay-title="Lock Screen" { spawn "${noctalia}" "msg" "session" "lock"; }
      Mod+Shift+E { quit; }
    }
  '';

  configFile = pkgs.runCommand "niri-config.kdl" {} ''
    ${lib.getExe pkgs.niri} validate -c ${rawConfig}
    cp ${rawConfig} $out
  '';
in {
  config = lib.mkIf isNiri {
    home = {
      packages = with pkgs; [
        playerctl
        xwayland-satellite
      ];

      sessionVariables.NIXOS_OZONE_WL = "1";
    };

    dconf.settings."org/gnome/desktop/interface".color-scheme = gtkColorScheme;

    gtk = {
      enable = true;
      font.name = "Noto Sans";
      theme = {
        name = gtkTheme;
        package = pkgs.gnome-themes-extra;
      };
      gtk3.extraConfig.gtk-application-prefer-dark-theme = !isLightTheme;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = !isLightTheme;
    };

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style.name = qtStyle;
    };

    services.gpg-agent.pinentry.package = pkgs.pinentry-gnome3;

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "GNOME polkit authentication agent";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    xdg = {
      configFile."niri/config.kdl".source = configFile;

      systemDirs.data = [
        "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
        "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      ];
    };
  };
}
