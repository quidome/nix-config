{ config, lib, pkgs, ... }:
let
  hyprlandEnabled = (config.my.gui == "hyprland");
in
{
  config = lib.mkIf hyprlandEnabled {
    my = {
      xdg.enable = true;
    };

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
    };

    services = {
      avizo.enable = true;
      mako.enable = true;
    };

    xdg.systemDirs.data = [
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    ];

  };
}
