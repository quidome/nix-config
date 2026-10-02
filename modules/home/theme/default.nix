{
  config,
  lib,
  pkgs,
  ...
}: let
  isDark = config.settings.theme == "dark";
  variant =
    if isDark
    then "Dark"
    else "Light";

  uiFont = "Noto Sans";
  monoFont = "JetBrainsMono Nerd Font";
  fontSize = 10;
  iconTheme = "Papirus-${variant}";

  # KDE apps read colors, style, icons and fonts from kdeglobals,
  # also outside Plasma.
  kdeFont = name: "${name},${toString fontSize},-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
  kdeglobals =
    builtins.readFile "${pkgs.kdePackages.breeze}/share/color-schemes/Breeze${variant}.colors"
    + lib.generators.toINI {} {
      General = {
        font = kdeFont uiFont;
        fixed = kdeFont monoFont;
        menuFont = kdeFont uiFont;
        smallestReadableFont = kdeFont uiFont;
        toolBarFont = kdeFont uiFont;
      };
      Icons.Theme = iconTheme;
      KDE.widgetStyle = "Breeze";
    };
in {
  # Plasma manages its own theme; this is for sessions without one.
  config = lib.mkIf (config.settings.gui == "niri") {
    home.packages = with pkgs; [
      adwaita-icon-theme
      noto-fonts
    ];

    fonts.fontconfig.defaultFonts = {
      sansSerif = [uiFont];
      monospace = [monoFont];
    };

    home.pointerCursor = {
      enable = true;
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    # Also sets the dark or light preference in dconf, which the portal
    # passes to libadwaita, Firefox and Electron apps.
    gtk = {
      enable = true;
      colorScheme = lib.toLower variant;
      font = {
        name = uiFont;
        size = fontSize;
      };
      iconTheme = {
        name = iconTheme;
        package = pkgs.papirus-icon-theme;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "kde";
      style.name = "breeze";
    };

    xdg.configFile."kdeglobals".text = kdeglobals;
  };
}
