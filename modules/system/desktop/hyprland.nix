{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "hyprland") {
    programs.hyprland = {
      enable = lib.mkDefault true;
      withUWSM = lib.mkDefault true;
      xwayland.enable = lib.mkDefault true;
    };

    services = {
      gnome.gnome-keyring.enable = lib.mkDefault true;

      greetd = {
        enable = lib.mkDefault true;
        settings.default_session = {
          user = "greeter";
          command = lib.mkDefault "${pkgs.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        };
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
      hyprlock = {};
    };

    xdg.portal.config.hyprland = {
      default = ["hyprland" "gtk"];
      "org.freedesktop.impl.portal.Settings" = "gtk";
    };

    environment = {
      systemPackages = with pkgs; [
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
