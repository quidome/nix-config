{ config, pkgs, lib, ... }:
with lib;

let
  swayEnabled = (config.my.gui == "sway");
in
{
  config = mkIf swayEnabled {
    my.profile = "workstation";
    networking.networkmanager.enable = true;

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

      networkmanagerapplet
      wofi
    ];

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true; # so that gtk works properly
    };

    # for qt theming
    qt5.platformTheme = "qt5ct";

    services.dbus.enable = true;

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
