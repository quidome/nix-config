{ config, pkgs, lib, ... }:
let
  alacrittyEnabled = config.programs.alacritty.enable;
in
{
  config.programs.alacritty.settings = lib.mkIf alacrittyEnabled {
    selection.save_to_clipboard = true;
    cursor.style = "beam";

    font = {
      size = 14;

      normal.family = "JetBrainsMono Nerd Font";
      normal.style = "Regular";
      bold.family = "JetBrainsMono Nerd Font";
      bold.style = "Bold";
      italic.family = "JetBrainsMono Nerd Font";
      italic.style = "Italic";
      bold_italic.family = "JetBrainsMono Nerd Font";
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
