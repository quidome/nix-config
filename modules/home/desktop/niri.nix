{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.settings.desktop.niri;
  noctalia = config.settings.programs.noctalia;
  isLight = config.settings.theme == "light";
  colorScheme =
    if isLight
    then "prefer-light"
    else "prefer-dark";
  gtkTheme =
    if isLight
    then "Adwaita"
    else "Adwaita Dark";
  preferDark = !isLight;
in {
  options.settings.desktop.niri = {
    enable = mkEnableOption "niri";
  };

  config = mkIf cfg.enable {
    services.gpg-agent.pinentry.package = pkgs.pinentry-gnome3;

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "niri";
    };

    xdg.mimeApps.enable = true;

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = colorScheme;
      };
    };

    gtk = {
      enable = true;
      font.name = "Noto Sans";
      theme.name = gtkTheme;
      theme.package = pkgs.gnome-themes-extra;
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = preferDark;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = preferDark;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style.name =
        if isLight
        then "adwaita"
        else "adwaita-dark";
    };

    settings.programs.niri.enable = mkDefault true;
    settings.programs.noctalia.enable = mkDefault false;

    programs = {
      ${config.settings.terminal}.enable = mkDefault true;
      swaylock.enable = mkDefault (!noctalia.enable);
      waybar.enable = mkDefault (!noctalia.enable);
    };

    services = {
      avizo.enable = mkDefault (!noctalia.enable);
      mako.enable = mkDefault (!noctalia.enable);
      kanshi.enable = mkDefault true;
    };

    settings.services.swayidle.enable = true;

    xdg.systemDirs.data = [
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    ];
  };
}
