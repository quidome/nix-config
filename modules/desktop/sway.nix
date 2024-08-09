{ config, pkgs, lib, ... }:
with lib;

let
  swayEnabled = (config.my.gui == "sway");
  networkmanagerEnabled = config.networking.networkmanager.enable;
  tailscaleEnabled = config.services.tailscale.enable;
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
      adwaita-qt
      libsForQt5.breeze-qt5
      libsForQt5.qt5ct

      (mkIf networkmanagerEnabled networkmanagerapplet)
      (mkIf tailscaleEnabled tailscale-systray)
      wl-clipboard
      wofi
    ];

    programs.gnupg.agent.enableSSHSupport = true;
    programs.dconf.enable = true;
    programs.sway.enable = true;
    programs.sway.wrapperFeatures.gtk = true; # so that gtk works properly

    # for qt theming
    qt.platformTheme = "qt5ct";

    services.auto-cpufreq.enable = true;
    services.dbus.enable = true;

    services.greetd.enable = true;
    services.greetd.settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd sway";

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
