{ config, lib, pkgs, ... }:
with lib;
let
  hyprlandEnabled = (config.my.gui == "hyprland");
  networkmanagerEnabled = config.networking.networkmanager.enable;
  tailscaleEnabled = config.services.tailscale.enable;
in
{
  config = lib.mkIf hyprlandEnabled {
    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };

      systemPackages = with pkgs; [
        avizo
        glib
        rofi-wayland
        wl-clipboard
        wofi
        (mkIf networkmanagerEnabled networkmanagerapplet)
        (mkIf tailscaleEnabled tailscale-systray)
      ];
    };

    hardware.opengl.enable = true;

    programs.gnupg.agent.enableSSHSupport = true;
    programs.dconf.enable = true;
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # for qt theming
    qt.platformTheme = "qt5ct";

    services.auto-cpufreq.enable = true;
    services.dbus.enable = true;
    services.greetd = {
      enable = true;
      settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
