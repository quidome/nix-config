{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  niriEnabled = config.settings.gui == "niri";
  networkmanagerEnabled = config.networking.networkmanager.enable;
  tailscaleEnabled = config.services.tailscale.enable;
in {
  config = mkIf niriEnabled {
    environment.systemPackages = with pkgs; [
      alacritty
      fuzzel
      swaylock
      mako
      swayidle
      unstable.noctalia-shell
      swaybg

      kdePackages.polkit-kde-agent-1

      (mkIf networkmanagerEnabled networkmanagerapplet)
      (mkIf tailscaleEnabled tailscale-systray)
    ];

    programs.niri.enable = true;

    security.polkit.enable = true; # polkit
    services.gnome.gnome-keyring.enable = true; # secret service
    security.pam.services.swaylock = {};

    programs.waybar.enable = true; # top bar
    qt.platformTheme = "qt5ct";

    services.auto-cpufreq.enable = true;
    services.dbus.enable = true;

    services.greetd.enable = true;
    services.greetd.settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd niri-session";

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];
    };
  };
}
