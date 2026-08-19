{
  config,
  lib,
  pkgs,
  ...
}: let
  sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
  tuigreetCommand = "${lib.getExe pkgs.tuigreet} --time --time-format '%a %F %H:%M' --remember --remember-user-session --asterisks --sessions ${sessions} --cmd ${config.programs.niri.package}/bin/niri-session";
in {
  config = lib.mkIf (config.settings.gui == "niri") {
    programs.niri.enable = lib.mkDefault true;

    environment = {
      systemPackages = [pkgs.glimpse];
      pathsToLink = [
        "/share/dbus-1/services"
        "/share/xdg-desktop-portal/portals"
      ];
    };

    security = {
      pam.services.glimpse-lock = {};
      polkit.enable = lib.mkDefault true;
      pam.services.greetd.enableGnomeKeyring = lib.mkDefault true;
    };

    services = {
      gnome.gnome-keyring.enable = lib.mkDefault true;
      power-profiles-daemon.enable = lib.mkDefault true;
      upower.enable = lib.mkDefault true;

      greetd = {
        enable = lib.mkDefault true;
        settings.default_session = {
          user = "greeter";
          command = lib.mkDefault tuigreetCommand;
        };
      };

      logind.settings.Login = {
        HandlePowerKey = lib.mkDefault "suspend";
        HandleLidSwitch = lib.mkDefault "suspend";
        HandleLidSwitchDocked = lib.mkDefault "ignore";
      };
    };
  };
}
