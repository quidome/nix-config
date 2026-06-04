{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  hyprAvizo = import ./hyprland/avizo.nix {inherit lib;};
  hyprIdle = import ./hyprland/hypridle.nix {inherit lib;};
  hyprInput = import ./hyprland/input.nix;
  hyprBind = import ./hyprland/bind.nix {inherit lib;};
  hyprLock = import ./hyprland/hyprlock.nix {inherit lib;};
  hyprMako = import ./hyprland/mako.nix {inherit config lib;};
  hyprPolkit = import ./hyprland/polkit.nix {inherit pkgs;};
  hyprSettingsCore = import ./hyprland/settings-core.nix {
    terminal = config.settings.terminal;
  };
  hyprRules = import ./hyprland/rules.nix {inherit lib;};
  hyprWaybar = import ./hyprland/waybar.nix {inherit lib;};
  isLightTheme = config.settings.theme == "light";
  gtkColorScheme =
    if isLightTheme
    then "prefer-light"
    else "prefer-dark";
  gtkTheme =
    if isLightTheme
    then "Adwaita"
    else "Adwaita Dark";
  networkmanagerEnabled = osConfig.networking.networkmanager.enable;
  qtStyle =
    if isLightTheme
    then "adwaita"
    else "adwaita-dark";
in {
  config = lib.mkIf (config.settings.gui == "hyprland") {
    home.packages = with pkgs; [
      grimblast
      libnotify
      playerctl
      thunar
      wdisplays
      wofi
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

    programs.hyprlock = hyprLock;
    programs.waybar = hyprWaybar;

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
      network-manager-applet.enable = lib.mkDefault networkmanagerEnabled;
    };

    xdg.systemDirs.data = [
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    ];

    xsession.preferStatusNotifierItems = lib.mkDefault true;

    systemd.user.services =
      {
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
      }
      // lib.optionalAttrs networkmanagerEnabled {
        network-manager-applet = {
          Unit = {
            After = lib.mkForce ["hyprland-session.target" "tray.target"];
            PartOf = lib.mkForce ["hyprland-session.target"];
          };
          Install.WantedBy = lib.mkForce ["hyprland-session.target"];
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
