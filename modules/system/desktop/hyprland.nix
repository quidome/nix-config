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
    };

    services.greetd = {
      enable = lib.mkDefault true;
      settings.default_session = {
        user = "greeter";
        command = lib.mkDefault "${pkgs.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
      };
    };

    xdg.portal.enable = lib.mkDefault true;
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}
