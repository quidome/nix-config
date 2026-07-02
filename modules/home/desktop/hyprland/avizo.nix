{
  config,
  lib,
}: let
  font = config.settings.terminalFont;
  isLightTheme = config.settings.theme == "light";
  colors =
    if isLightTheme
    then {
      base = "#eff1f5";
      text = "#4c4f69";
      overlay = "#9ca0b0";
      accent = "#1e66f5";
    }
    else {
      base = "#1e1e2e";
      text = "#cdd6f4";
      overlay = "#6c7086";
      accent = "#89b4fa";
    };
in {
  enable = lib.mkDefault true;

  settings.default = {
    time = 1.0;
    y-offset = 0.5;
    fade-in = 0.1;
    fade-out = 0.2;
    padding = 10;
    border-radius = 8;
    border-width = 2;
    background = colors.base;
    foreground = colors.text;
    border-color = colors.overlay;
    bar-bg-color = colors.overlay;
    bar-fg-color = colors.accent;
    font = "${font.name} ${toString font.size}";
  };
}
