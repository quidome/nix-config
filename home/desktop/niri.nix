{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  niriEnabled = config.settings.gui == "niri";
in {
  config = mkIf niriEnabled {
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

    programs = {
      alacritty.enable = mkDefault (terminal == "alacritty");
      kitty.enable = mkDefault (terminal == "kitty");
      wezterm.enable = mkDefault (terminal == "wezterm");

      waybar.enable = mkDefault true;
      # wofi.enable = mkDefault true;
    };

    # services = {
    # avizo.enable = mkDefault true;
    # hypridle.enable = mkDefault true;
    # mako.enable = mkDefault true;
    # shikane.enable = mkDefault true;
    # };

    xdg.systemDirs.data = [
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    ];
  };
}
