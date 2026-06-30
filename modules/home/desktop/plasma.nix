{
  config,
  lib,
  ...
}:
with lib; let
  isPlasma = config.settings.gui == "plasma";
  isLight = config.settings.theme == "light";
  konsoleTheme =
    if isLight
    then "Catppuccin_Latte"
    else "Catppuccin_Mocha";
  konsoleThemeLabel =
    if isLight
    then "Catppuccin Latte"
    else "Catppuccin Mocha";
  useKonsoleTheme = isPlasma && config.settings.terminal == "konsole";
in {
  config = mkIf isPlasma {
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
    };

    settings.terminal = mkDefault "konsole";

    xdg.dataFile = mkIf useKonsoleTheme {
      "konsole/Catppuccin_Latte.colorscheme".source = ../dotfiles/Catppuccin_Latte.colorscheme;
      "konsole/Catppuccin_Mocha.colorscheme".source = ../dotfiles/Catppuccin_Mocha.colorscheme;
      "konsole/${konsoleTheme}.profile".text = ''
        [Appearance]
        ColorScheme=${konsoleTheme}

        [General]
        Name=${konsoleThemeLabel}
        Parent=FALLBACK/
      '';
    };

    xdg.configFile."konsolerc" = mkIf useKonsoleTheme {
      text = ''
        [Desktop Entry]
        DefaultProfile=${konsoleTheme}.profile
      '';
    };
  };
}
