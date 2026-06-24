{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  isPlasma = config.settings.gui == "plasma";
in {
  config = mkIf isPlasma {
    services.displayManager = {
      sddm = {
        enable = mkDefault true;
        wayland.enable = mkDefault true;
      };
      defaultSession = mkDefault "plasma";
    };

    services.desktopManager.plasma6.enable = mkDefault true;

    services.xserver.enable = mkDefault true;

    xdg.portal = {
      enable = mkDefault true;
      extraPortals = mkDefault [pkgs.kdePackages.xdg-desktop-portal-kde];
    };
  };
}
