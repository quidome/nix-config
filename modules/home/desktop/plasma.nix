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

    xdg.dataFile = mkIf useKonsoleTheme {
      "konsole/Catppuccin_Latte.colorscheme".source = ../dotfiles/Catppuccin_Latte.colorscheme;
      "konsole/Catppuccin_Mocha.colorscheme".source = ../dotfiles/Catppuccin_Mocha.colorscheme;
      "konsole/${konsoleTheme}.profile".text = ''
        [Appearance]
        ColorScheme=${konsoleTheme}
        Font=${config.settings.terminalFont.name},${toString config.settings.terminalFont.size},-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0

        [General]
        Name=${konsoleThemeLabel}
        Parent=FALLBACK/
        TerminalColumns=120
        TerminalRows=40

        [Scrolling]
        HistorySize=10000
        ScrollBarPosition=2
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
