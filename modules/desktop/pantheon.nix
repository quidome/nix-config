{ config, lib, pkgs, ... }:
with lib;
let
  pantheonEnabled = (config.settings.gui == "pantheon");
in
{
  config = mkIf pantheonEnabled {
    environment = {
      pantheon.excludePackages = with pkgs.pantheon; [
        epiphany
        elementary-music
        elementary-videos
      ];

      # App indicator
      # - https://discourse.nixos.org/t/anyone-with-pantheon-de/28422
      # - https://github.com/NixOS/nixpkgs/issues/144045#issuecomment-992487775
      pathsToLink = [ "/libexec" ];

      systemPackages = with pkgs; [
        appeditor
        formatter
        gnome.simple-scan
        pick-colour-picker
        yaru-theme
      ];
    };

    programs = {
      evince.enable = true;
      gnome-disks.enable = true;
      gnupg.agent.enableSSHSupport = true;
      pantheon-tweaks.enable = true;
      seahorse.enable = true;

      dconf.profiles.user.databases = [{
        settings = {
          "io/elementary/desktop/wingpanel" = {
            use-transparency = false;
          };

          "io/elementary/settings-daemon/datetime" = {
            show-weeks = true;
          };

          "net/launchpad/plank/docks/dock1" = {
            alignment = "center";
            hide-mode = "window-dodge";
            icon-size = lib.gvariant.mkInt32 48;
            pinned-only = false;
            # position = "left";
            theme = "Transparent";
          };

          "org/gnome/desktop/datetime" = {
            automatic-timezone = true;
          };

          "org/gtk/gtk4/Settings/FileChooser" = {
            clock-format = "24h";
          };

          "org/gtk/Settings/FileChooser" = {
            clock-format = "24h";
          };

          "org/pantheon/desktop/gala/appearance" = {
            button-layout = ":minimize,maximize,close";
          };
        };
      }];
    };

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    services = {
      gnome = {
        evolution-data-server.enable = true;
        gnome-online-accounts.enable = true;
        gnome-keyring.enable = true;
      };
      gvfs.enable = true;
      printing.enable = true;
      xserver = {
        enable = true;
        displayManager.lightdm.enable = true;
        displayManager.lightdm.greeters.pantheon.enable = true;

        desktopManager.pantheon.enable = true;
        desktopManager.pantheon.extraWingpanelIndicators = with pkgs; [
          wingpanel-indicator-ayatana
          monitor
        ];
      };
    };

    # App indicator
    # - https://github.com/NixOS/nixpkgs/issues/144045#issuecomment-992487775
    systemd.user.services.indicator-application-service = {
      description = "indicator-application-service";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.indicator-application-gtk3}/libexec/indicator-application/indicator-application-service";
      };
    };

    xdg.portal.config.pantheon = {
      default = [
        "pantheon"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Secret" = [
        "gnome-keyring"
      ];
    };
  };
}
