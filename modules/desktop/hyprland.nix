{ config, lib, pkgs, ... }:
let
  hyprlandEnabled = (config.my.gui == "hyprland");
in
{
  config = lib.mkIf hyprlandEnabled {

    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };

      systemPackages = with pkgs; [
        rofi-wayland
      ];
    };

    hardware.opengl.enable = true;

    services = {
      dbus.enable = true;
      greetd = {
        enable = true;
        settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
      };
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };
}
