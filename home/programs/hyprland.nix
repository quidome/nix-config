{ config, lib, pkgs, ... }:
let
  hyprlandEnabled = (config.my.gui == "hyprland");
in
{
  config = lib.mkIf hyprlandEnabled {

    home.packages = with pkgs; [
      playerctl
    ];

    xdg.mimeApps.enable = true;

    gtk = {
      enable = true;
      font.name = "Noto Sans";
      theme.name = "Adwaita";
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

    programs = {
      alacritty.enable = true;
      hyprlock.enable = true;
      waybar.enable = true;
    };

    settings.waybar.modules-left = [ "hyprland/workspaces" "hyprland/mode" ];

    services = {
      avizo.enable = true;
      hypridle.enable = true;
      mako.enable = true;
    };

    xdg.systemDirs.data = [
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    ];
  };
}
