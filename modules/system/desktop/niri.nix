{
  config,
  lib,
  pkgs,
  ...
}: let
  sessions = "${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
in {
  config = lib.mkIf (config.settings.gui == "niri") {
    programs.niri.enable = lib.mkDefault true;

    services = {
      power-profiles-daemon.enable = lib.mkDefault true;
      upower.enable = lib.mkDefault true;

      greetd = {
        enable = lib.mkDefault true;
        settings.default_session = {
          user = "greeter";
          command = lib.mkDefault "${lib.getExe pkgs.tuigreet} --sessions ${sessions}";
        };
      };

      logind.settings.Login = {
        HandlePowerKey = lib.mkDefault "suspend";
        HandleLidSwitch = lib.mkDefault "suspend";
        HandleLidSwitchDocked = lib.mkDefault "ignore";
      };
    };

    # Keep boot logs from spamming the greetd TTY.
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
      swaylock = {};
    };

    environment = {
      systemPackages = with pkgs; [
        swaybg
      ];

      pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];
    };
  };
}
