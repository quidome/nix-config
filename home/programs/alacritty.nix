{ config, pkgs, lib, ... }:
with lib;
let
  alacrittyEnabled = config.programs.alacritty.enable;
  font = "FiraCode Nerd Font";
  fontSize = (if pkgs.stdenv.isDarwin then 14 else 11);
in
{
  config.programs.alacritty.settings = mkIf alacrittyEnabled {
    selection.save_to_clipboard = true;
    cursor.style = "beam";

    font = {
      size = fontSize;

      normal.family = font;
      normal.style = "Regular";
      bold.family = font;
      bold.style = "Bold";
      italic.family = font;
      italic.style = "Italic";
      bold_italic.family = font;
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

    window = {
      option_as_alt = mkIf pkgs.stdenv.isDarwin "Both";
    };

    shell = mkIf pkgs.stdenv.isDarwin {
      program = "login";
      args = [ "-fp" config.home.username ];
    };
  };
}
