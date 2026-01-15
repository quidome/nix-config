{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.settings.desktop.niri;
in {
  options.settings.desktop.niri = {
    enable = mkEnableOption "niri";
    noctalia.enable = mkEnableOption "noctalia";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "niri";
    };

    xdg.mimeApps.enable = true;

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    gtk = {
      enable = true;
      font.name = "Noto Sans";
      theme.name = "Adwaita Dark";
      theme.package = pkgs.gnome-themes-extra;
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style.name = "adwaita-dark";
    };

    programs.niri.enable = mkDefault true;

    programs = {
      ghostty.enable = mkDefault true;
      noctalia.enable = cfg.noctalia.enable;
      swaylock.enable = mkDefault (!cfg.noctalia.enable);
      waybar.enable = mkDefault (!cfg.noctalia.enable);
    };

    services = {
      avizo.enable = mkDefault (!cfg.noctalia.enable);
      mako.enable = mkDefault (!cfg.noctalia.enable);
      kanshi.enable = mkDefault true;
    };

    xdg.systemDirs.data = [
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    ];
  };
}
