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
        (mkIf networkmanagerEnabled networkmanagerapplet)
        (mkIf tailscaleEnabled tailscale-systray)
      ];
    };

    programs.gnupg.agent.enableSSHSupport = true;
    programs.dconf.enable = true;
    programs.hyprland.enable = true;

    # for qt theming
    qt.platformTheme = "qt5ct";

    services.auto-cpufreq.enable = true;
    services.greetd = {
      enable = true;
      settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
