{ config, pkgs, lib, ... }:
with lib;

let
  swayEnabled = (config.my.gui == "sway");
  networkmanagerEnabled = config.networking.networkmanager.enable;
in
{
  config = mkIf swayEnabled {
    environment.systemPackages = with pkgs; [
      # gtk theming
      glib
      gtk-engine-murrine
      gnome.adwaita-icon-theme
      gtk_engines
      gsettings-desktop-schemas
      lxappearance

      # qt theming
      libsForQt5.breeze-qt5
      adwaita-qt

      (mkIf networkmanagerEnabled networkmanagerapplet)
      wofi
    ];

    programs.dconf.enable = true;

    programs.sway.enable = true;
    programs.sway.wrapperFeatures.gtk = true; # so that gtk works properly

    # for qt theming
    qt.platformTheme = "qt5ct";

    services.auto-cpufreq.enable = true;
    services.dbus.enable = true;

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
