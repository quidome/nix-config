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

    colors = {
      # Default colors;
      primary = {
        background = "0x282828";
        foreground = "0xeeeeee";
      };
      # Normal colors;
      normal = {
        black = "0x282828";
        red = "0xf43753";
        green = "0xc9d05c";
        yellow = "0xffc24b";
        blue = "0xb3deef";
        magenta = "0xd3b987";
        cyan = "0x73cef4";
        white = "0xeeeeee";
      };
      # Bright colors;
      bright = {
        black = "0x4c4c4c";
        red = "0xf43753";
        green = "0xc9d05c";
        yellow = "0xffc24b";
        blue = "0xb3deef";
        magenta = "0xd3b987";
        cyan = "0x73cef4";
        white = "0xfeffff";
      };
    };
  };
}
