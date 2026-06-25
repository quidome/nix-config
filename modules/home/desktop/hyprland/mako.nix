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
      surface = "#ccd0da";
      overlay = "#9ca0b0";
      accent = "#1e66f5";
      red = "#d20f39";
    }
    else {
      base = "#1e1e2e";
      text = "#cdd6f4";
      surface = "#313244";
      overlay = "#6c7086";
      accent = "#89b4fa";
      red = "#f38ba8";
    };
in {
  enable = lib.mkDefault true;

  settings = {
    default-timeout = 10000;
    group-by = "summary";
    anchor = "bottom-right";
    font = "${font.name} ${toString font.size}";
    width = 360;
    height = 120;
    padding = "12,14";
    margin = "12,12";
    border-size = 2;
    border-radius = 8;
    icons = true;
    max-icon-size = 48;

    background-color = colors.base;
    text-color = colors.text;
    border-color = colors.overlay;
    progress-color = "over ${colors.accent}";

    grouped.format = "<b>%s</b>\\n%bd";

    "urgency=low" = {
      border-color = colors.surface;
    };

    "urgency=normal" = {
      border-color = colors.accent;
    };

    "urgency=high" = {
      border-color = colors.red;
      text-color = colors.red;
      default-timeout = 0;
    };
  };
}
