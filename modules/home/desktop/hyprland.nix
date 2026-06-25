{
  config,
  lib,
  pkgs,
  ...
}: let
  hyprAvizo = import ./hyprland/avizo.nix {inherit config lib;};
  hyprIdle = import ./hyprland/hypridle.nix {inherit lib;};
  hyprInput = import ./hyprland/input.nix;
  hyprBind = import ./hyprland/bind.nix {inherit lib;};
  hyprLock = import ./hyprland/hyprlock.nix {inherit config lib;};
  hyprMako = import ./hyprland/mako.nix {inherit config lib;};
  hyprPolkit = import ./hyprland/polkit.nix {inherit pkgs;};
  hyprSettingsCore = import ./hyprland/settings-core.nix {
    inherit config;
    terminal = config.settings.terminal;
  };
  hyprRules = import ./hyprland/rules.nix {};
  hyprWaybar = import ./hyprland/waybar.nix {inherit config lib;};
  isLightTheme = config.settings.theme == "light";
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
  launcherTerminal =
    if config.settings.terminal == "wezterm"
    then "wezterm start --always-new-process --"
    else "${config.settings.terminal} -e";
in {
  config = lib.mkIf (config.settings.gui == "hyprland") {
    home.packages = with pkgs; [
      grimblast
      libnotify
      playerctl
      thunar
      wdisplays
    ];

    dconf.settings."org/gnome/desktop/interface" = {
      color-scheme = gtkColorScheme;
    };

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
        settings = {
          main = {
            launch-prefix = "uwsm app --";
            terminal = launcherTerminal;
            font = "JetBrainsMono Nerd Font:size=13";
            width = 60;
            lines = 8;
            horizontal-pad = 16;
            vertical-pad = 12;
            inner-pad = 8;
          };
          border = {
            width = 2;
            radius = 8;
          };
          colors = {
            background = "${
              if isLightTheme
              then "eff1f5ee"
              else "1e1e2eee"
            }";
            text = "${
              if isLightTheme
              then "4c4f69ff"
              else "cdd6f4ff"
            }";
            match = "${
              if isLightTheme
              then "1e66f5ff"
              else "89b4faff"
            }";
            selection = "${
              if isLightTheme
              then "ccd0daff"
              else "313244ff"
            }";
            selection-text = "${
              if isLightTheme
              then "4c4f69ff"
              else "cdd6f4ff"
            }";
            selection-match = "${
              if isLightTheme
              then "1e66f5ff"
              else "89b4faff"
            }";
            border = "${
              if isLightTheme
              then "9ca0b0ff"
              else "6c7086ff"
            }";
          };
        };
      };
      hyprlock = hyprLock;
      waybar = hyprWaybar;
    };

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style.name = qtStyle;
    };

    services = {
      avizo = hyprAvizo;
      gpg-agent.pinentry.package = pkgs.pinentry-gnome3;
      hypridle = hyprIdle;
      kanshi.systemdTarget = lib.mkDefault "hyprland-session.target";
      mako = hyprMako;
    };

    xdg = {
      portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
      systemDirs.data = [
        "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
        "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      ];
    };

    xsession.preferStatusNotifierItems = lib.mkDefault true;

    systemd.user.services = {
      polkit-gnome-authentication-agent-1 = hyprPolkit;

      avizo = {
        Unit = {
          After = lib.mkForce ["hyprland-session.target"];
          PartOf = lib.mkForce ["hyprland-session.target"];
        };
        Install.WantedBy = lib.mkForce ["hyprland-session.target"];
      };

      mako = {
        Unit = {
          Description = "Lightweight Wayland notification daemon";
          After = ["hyprland-session.target"];
          PartOf = ["hyprland-session.target"];
          ConditionEnvironment = "WAYLAND_DISPLAY";
        };
        Service = {
          ExecStart = "${lib.getExe pkgs.mako}";
          Restart = "on-failure";
        };
        Install.WantedBy = ["hyprland-session.target"];
      };
    };

    wayland.windowManager.hyprland = {
      enable = lib.mkDefault true;
      settings = lib.recursiveUpdate hyprSettingsCore (
        lib.recursiveUpdate hyprRules {
          config.input = hyprInput;
          bind = hyprBind;
        }
      );
    };
  };
}
