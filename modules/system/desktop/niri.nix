{
  config,
  lib,
  pkgs,
  ...
}: let
  sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
  tuigreetCommand = "${lib.getExe pkgs.tuigreet} --time --time-format '%a %F %H:%M' --remember --asterisks --sessions ${sessions} --cmd ${config.programs.niri.package}/bin/niri-session";
in {
  config = lib.mkIf (config.settings.gui == "niri") {
    environment.systemPackages = with pkgs; [
      ghostty
      pavucontrol
    ];

    programs.niri.enable = lib.mkDefault true;

    security = {
      polkit.enable = lib.mkDefault true;
      pam.services = {
        greetd.enableGnomeKeyring = lib.mkDefault true;
        # Noctalia's lock screen authenticates passwords against `login` and
        # drives fprintd itself over D-Bus; pam_fprintd would fight it for the sensor.
        login.fprintAuth = lib.mkIf config.services.fprintd.enable false;
      };
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
