{
  config,
  lib,
  pkgs,
  ...
}: let
  isNiri = config.settings.gui == "niri";
  isLightTheme = config.settings.theme == "light";
  terminal = config.settings.terminal;
  launcherTerminal =
    if terminal == "wezterm"
    then "wezterm start --always-new-process --"
    else "${terminal} -e";
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
  niriAvizo = import ./hyprland/avizo.nix {inherit config lib;};
  niriMako = import ./hyprland/mako.nix {inherit config lib;};
  niriWaybar = import ./niri/waybar.nix {inherit config lib;};
  wallpaper = config.settings.wallpaper;
  wallpaperCommand =
    if wallpaper == null
    then "${lib.getExe pkgs.swaybg} -c '#101010'"
    else "${lib.getExe pkgs.swaybg} -i ${lib.escapeShellArg wallpaper} -m fill";
  lockScript = pkgs.writeShellScript "niri-lock" ''
    ${pkgs.procps}/bin/pgrep -u "$UID" -x swaylock >/dev/null && exit 0
    exec ${pkgs.swaylock}/bin/swaylock -f
  '';
  idleProfiles = {
    ac = {
      lock = 900;
      monitorsOff = 1800;
      suspend = 3600;
    };
    battery = {
      lock = 300;
      monitorsOff = 600;
      suspend = 1800;
    };
  };
  idleAction = pkgs.writeShellScript "niri-idle-action" ''
    set -eu

    profile="$1"
    action="$2"
    on_ac=false
    if ${pkgs.systemd}/bin/systemd-ac-power >/dev/null 2>&1; then
      on_ac=true
    fi

    if [[ "$profile" == ac && "$on_ac" != true ]]; then
      exit 0
    fi
    if [[ "$profile" == battery && "$on_ac" == true ]]; then
      exit 0
    fi

    case "$action" in
      lock)
        ${pkgs.systemd}/bin/loginctl lock-session
        ;;
      monitors-off)
        ${pkgs.niri}/bin/niri msg action power-off-monitors
        ;;
      suspend)
        ${pkgs.systemd}/bin/systemctl suspend
        ;;
      *)
        exit 2
        ;;
    esac
  '';
  powerMonitor = pkgs.writeShellScript "niri-power-monitor" ''
    set -euo pipefail

    current_power_state() {
      if ${pkgs.systemd}/bin/systemd-ac-power >/dev/null 2>&1; then
        printf '%s\n' ac
      else
        printf '%s\n' battery
      fi
    }

    stable_state="$(current_power_state)"
    debounce_seconds=5

    ${pkgs.upower}/bin/upower --monitor |
      while IFS= read -r changed; do
        case "$changed" in
          *line_power*)
            while IFS= read -r -t "$debounce_seconds" changed; do
              :
            done

            current_state="$(current_power_state)"
            if [[ "$current_state" != "$stable_state" ]]; then
              ${pkgs.systemd}/bin/systemctl --user restart swayidle.service
              stable_state="$current_state"
            fi
            ;;
        esac
      done
  '';
  lockColors =
    if isLightTheme
    then {
      background = "eff1f5";
      text = "4c4f69";
      accent = "1e66f5";
      failure = "d20f39";
    }
    else {
      background = "1e1e2e";
      text = "cdd6f4";
      accent = "89b4fa";
      failure = "f38ba8";
    };
in {
  config = lib.mkIf isNiri {
    home = {
      packages = with pkgs; [
        brightnessctl
        playerctl
        xwayland-satellite
      ];

      sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
        XDG_CURRENT_DESKTOP = "niri";
      };
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

    programs = {
      fuzzel = {
        enable = lib.mkDefault true;
        settings.main = {
          terminal = launcherTerminal;
          font = "${config.settings.terminalFont.name}:size=13";
          width = 60;
          lines = 8;
          horizontal-pad = 16;
          vertical-pad = 12;
          inner-pad = 8;
        };
      };

      swaylock = {
        enable = lib.mkDefault true;
        settings =
          {
            color = lockColors.background;
            font = config.settings.terminalFont.name;
            font-size = 20;
            indicator-radius = 90;
            indicator-thickness = 8;
            inside-color = "${lockColors.background}dd";
            inside-clear-color = "${lockColors.accent}dd";
            inside-ver-color = "${lockColors.accent}dd";
            inside-wrong-color = "${lockColors.failure}dd";
            key-hl-color = lockColors.accent;
            line-color = "00000000";
            ring-color = lockColors.text;
            ring-clear-color = lockColors.accent;
            ring-ver-color = lockColors.accent;
            ring-wrong-color = lockColors.failure;
            separator-color = "00000000";
            show-failed-attempts = true;
            text-color = lockColors.text;
          }
          // lib.optionalAttrs (wallpaper != null) {
            image = wallpaper;
            scaling = "fill";
          };
      };

      waybar = niriWaybar;
    };

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style.name = qtStyle;
    };

    services = {
      avizo = niriAvizo;
      gpg-agent.pinentry.package = pkgs.pinentry-gnome3;
      mako = niriMako;
      swayidle = {
        enable = lib.mkDefault true;
        systemdTargets = ["graphical-session.target"];
        events = {
          after-resume = "${pkgs.niri}/bin/niri msg action power-on-monitors";
          lock = "${lockScript}";
          before-sleep = "${lockScript}";
        };
        timeouts = [
          {
            timeout = idleProfiles.battery.lock;
            command = "${idleAction} battery lock";
          }
          {
            timeout = idleProfiles.battery.monitorsOff;
            command = "${idleAction} battery monitors-off";
            resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
          }
          {
            timeout = idleProfiles.battery.suspend;
            command = "${idleAction} battery suspend";
          }
          {
            timeout = idleProfiles.ac.lock;
            command = "${idleAction} ac lock";
          }
          {
            timeout = idleProfiles.ac.monitorsOff;
            command = "${idleAction} ac monitors-off";
            resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
          }
          {
            timeout = idleProfiles.ac.suspend;
            command = "${idleAction} ac suspend";
          }
        ];
      };
    };

    systemd.user.services = {
      polkit-gnome-authentication-agent-1 = {
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

      avizo = {
        Unit = {
          After = lib.mkForce ["graphical-session.target"];
          PartOf = lib.mkForce ["graphical-session.target"];
        };
        Install.WantedBy = lib.mkForce ["graphical-session.target"];
      };

      mako = {
        Unit = {
          Description = "Lightweight Wayland notification daemon";
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
          ConditionEnvironment = "WAYLAND_DISPLAY";
        };
        Service = {
          ExecStart = "${lib.getExe pkgs.mako}";
          Restart = "on-failure";
        };
        Install.WantedBy = ["graphical-session.target"];
      };

      swaybg = {
        Unit = {
          Description = "Niri wallpaper";
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
          ConditionEnvironment = "WAYLAND_DISPLAY";
        };
        Service = {
          Type = "exec";
          ExecStart = wallpaperCommand;
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install.WantedBy = ["graphical-session.target"];
      };

      niri-power-monitor = {
        Unit = {
          Description = "Restart Niri idle timers when power changes";
          After = ["graphical-session.target" "swayidle.service"];
          PartOf = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${powerMonitor}";
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install.WantedBy = ["graphical-session.target"];
      };
    };

    xsession.preferStatusNotifierItems = lib.mkDefault true;

    xdg = {
      configFile."niri/config.kdl".text = ''
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

            Mod+Return hotkey-overlay-title="Open ${terminal}" { spawn "${terminal}"; }
            Mod+D hotkey-overlay-title="Run an Application" { spawn "fuzzel"; }
            Mod+O repeat=false { toggle-overview; }
            Mod+Q repeat=false { close-window; }

            XF86AudioRaiseVolume allow-when-locked=true { spawn "${pkgs.avizo}/bin/volumectl" "-u" "up"; }
            XF86AudioLowerVolume allow-when-locked=true { spawn "${pkgs.avizo}/bin/volumectl" "-u" "down"; }
            XF86AudioMute allow-when-locked=true { spawn "${pkgs.avizo}/bin/volumectl" "toggle-mute"; }
            XF86MonBrightnessUp allow-when-locked=true { spawn "${pkgs.avizo}/bin/lightctl" "up"; }
            XF86MonBrightnessDown allow-when-locked=true { spawn "${pkgs.avizo}/bin/lightctl" "down"; }
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

            Mod+Alt+L hotkey-overlay-title="Lock Screen" { spawn "${pkgs.systemd}/bin/loginctl" "lock-session"; }
            Mod+Shift+E { quit; }
          }
      '';

      systemDirs.data = [
        "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
        "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      ];
    };
  };
}
