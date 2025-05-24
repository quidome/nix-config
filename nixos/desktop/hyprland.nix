{ config, lib, pkgs, ... }:
with lib;
let
  hyprlandEnabled = (config.settings.gui == "hyprland");
  networkmanagerEnabled = config.networking.networkmanager.enable;
  tailscaleEnabled = config.services.tailscale.enable;
in
{
  config = mkIf hyprlandEnabled {
    environment = {
      systemPackages = with pkgs; [
        # hyprland deps
        avizo
        hyprpicker
        hyprcursor
        hyprlock
        hypridle
        hyprpaper
        libnotify
        waybar
        wdisplays

        # Theming
        glib
        adwaita-icon-theme
        gsettings-desktop-schemas
        gtk-engine-murrine
        gtk_engines
        lxappearance

        # qt theming
        adwaita-qt
        libsForQt5.breeze-qt5
        libsForQt5.qt5ct

        kdePackages.polkit-kde-agent-1

        (mkIf networkmanagerEnabled networkmanagerapplet)
        (mkIf tailscaleEnabled tailscale-systray)
      ];
    };

    programs.gnupg.agent.enableSSHSupport = true;
    programs.hyprland.enable = true;
    programs.hyprland.withUWSM = true;
    programs.hyprlock.enable = true;
    programs.thunar.enable = true;

    # for qt theming
    qt.platformTheme = "qt5ct";

    security.pam.services.hyprlock = { };

    services.auto-cpufreq.enable = true;
    services.greetd.enable = true;

    services.logind.extraConfig = "HandlePowerKey=suspend";

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
