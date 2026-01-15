{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.qm.home.desktop.niri;
in {
  options.qm.home.desktop.niri = {
    enable = mkEnableOption "niri";
    noctaliaEnabled = mkEnableOption "noctalia";
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

    qm.programs.niri.enable = mkDefault true;

    programs = {
      ghostty.enable = mkDefault true;
      noctalia.enable = config.qm.home.desktop.niri.noctaliaEnabled;
      swaylock.enable = mkDefault (!config.qm.home.desktop.niri.noctaliaEnabled);
      waybar.enable = mkDefault (!config.qm.home.desktop.niri.noctaliaEnabled);
    };

    services = {
      avizo.enable = mkDefault (!config.qm.home.desktop.niri.noctaliaEnabled);
      mako.enable = mkDefault (!config.qm.home.desktop.niri.noctaliaEnabled);
      kanshi.enable = mkDefault true;
    };

    xdg.systemDirs.data = [
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    ];
  };
}
