{
  config,
  lib,
  pkgs,
  ...
}: let
  sessions = "${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
  uwsmHyprlandCmd = "${lib.getExe pkgs.uwsm} start -e -D Hyprland hyprland.desktop";
  electronSecretStoreFlags = "--password-store=gnome-libsecret";

  elementDesktop = pkgs.symlinkJoin {
    name = "element-desktop";
    paths = [pkgs.element-desktop];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      rm $out/bin/element-desktop
      makeWrapper ${lib.getExe pkgs.element-desktop} $out/bin/element-desktop \
        --add-flags "${electronSecretStoreFlags}"

      rm $out/share/applications/element-desktop.desktop
      cp ${pkgs.element-desktop}/share/applications/element-desktop.desktop $out/share/applications/element-desktop.desktop
      substituteInPlace $out/share/applications/element-desktop.desktop \
        --replace-fail "Exec=element-desktop %u" "Exec=element-desktop ${electronSecretStoreFlags} %u"
    '';
  };

  signalDesktop = pkgs.symlinkJoin {
    name = "signal-desktop";
    paths = [pkgs.signal-desktop];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      rm $out/bin/signal-desktop
      makeWrapper ${lib.getExe pkgs.signal-desktop} $out/bin/signal-desktop \
        --add-flags "${electronSecretStoreFlags}"

      rm $out/share/applications/signal.desktop
      cp ${pkgs.signal-desktop}/share/applications/signal.desktop $out/share/applications/signal.desktop
      substituteInPlace $out/share/applications/signal.desktop \
        --replace-fail "Exec=signal-desktop %U" "Exec=signal-desktop ${electronSecretStoreFlags} %U"
    '';
  };
in {
  config = lib.mkIf (config.settings.gui == "hyprland") {
    programs.hyprland = {
      enable = lib.mkDefault true;
      withUWSM = lib.mkDefault true;
      xwayland.enable = lib.mkDefault true;
    };

    services = {
      gnome.gnome-keyring.enable = lib.mkDefault true;
      power-profiles-daemon.enable = lib.mkDefault true;
      upower.enable = lib.mkDefault true;

      greetd = {
        enable = lib.mkDefault true;
        settings.default_session = {
          user = "greeter";
          command = lib.mkDefault "${lib.getExe pkgs.tuigreet} --cmd ${lib.escapeShellArg uwsmHyprlandCmd} --sessions ${sessions}";
        };
      };

      logind.settings.Login = {
        HandlePowerKey = lib.mkDefault "suspend";
        HandleLidSwitch = lib.mkDefault "suspend";
        HandleLidSwitchDocked = lib.mkDefault "ignore";
      };
    };

    security.pam.services = {
      greetd.enableGnomeKeyring = lib.mkDefault true;
      hyprlock = {};
    };

    xdg.portal.config.hyprland = {
      default = ["hyprland" "gtk"];
      "org.freedesktop.impl.portal.Settings" = "gtk";
    };

    environment = {
      systemPackages = with pkgs; [
        elementDesktop
        gcr
        libsecret
        seahorse
        signalDesktop
      ];

      pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];
    };
  };
}
