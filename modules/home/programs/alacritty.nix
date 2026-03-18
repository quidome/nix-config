{
  config,
  lib,
  ...
}: let
  cfg = config.programs.alacritty;
  font = config.settings.terminalFont;
in {
  config.programs.alacritty.settings = lib.mkIf cfg.enable {
    selection.save_to_clipboard = true;
    cursor.style = "beam";

    font = {
      size = font.size;

      normal.family = font.name;
      normal.style = "Regular";
      bold.family = font.name;
      bold.style = "Bold";
      italic.family = font.name;
      italic.style = "Italic";
      bold_italic.family = font.name;
      bold_italic.style = "Bold Italic";
    };
  };
}
