{ config, lib, pkgs, ... }:
with lib;
let
  hyprlandEnabled = (config.settings.gui == "hyprland");
in
{
  config = mkIf hyprlandEnabled {

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
      alacritty.enable = mkDefault true;
      hyprlock.enable = mkDefault true;
      kitty.enable = mkDefault false;
      waybar.enable = mkDefault true;
      wofi.enable = mkDefault true;
    };

    settings.waybar.modules-left = [ "hyprland/workspaces" "hyprland/mode" ];

    services = {
      avizo.enable = mkDefault true;
      hypridle.enable = mkDefault true;
      kanshi.enable = mkDefault true;
      mako.enable = mkDefault true;
    };

    xdg.systemDirs.data = [
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    ];
  };
}
