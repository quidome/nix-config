{
  config,
  lib,
  pkgs,
  ...
}: let
  sessions = "${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
  uwsmHyprlandCmd = "${lib.getExe pkgs.uwsm} start -e -D Hyprland hyprland.desktop";
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

    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
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
        gcr
        libsecret
        seahorse
      ];

      pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];
    };
  };
}
