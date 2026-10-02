# Catppuccin colors (hex, without "#"): Mocha for dark, Latte for light.
# https://catppuccin.com/palette
theme: let
  mocha = {
    rosewater = "f5e0dc";
    pink = "f5c2e7";
    red = "f38ba8";
    peach = "fab387";
    yellow = "f9e2af";
    green = "a6e3a1";
    teal = "94e2d5";
    blue = "89b4fa";
    text = "cdd6f4";
    subtext1 = "bac2de";
    subtext0 = "a6adc8";
    overlay1 = "7f849c";
    overlay0 = "6c7086";
    surface2 = "585b70";
    surface1 = "45475a";
    surface0 = "313244";
    base = "1e1e2e";
    mantle = "181825";
    crust = "11111b";
  };
  latte = {
    rosewater = "dc8a78";
    pink = "ea76cb";
    red = "d20f39";
    peach = "fe640b";
    yellow = "df8e1d";
    green = "40a02b";
    teal = "179299";
    blue = "1e66f5";
    text = "4c4f69";
    subtext1 = "5c5f77";
    subtext0 = "6c6f85";
    overlay1 = "8c8fa1";
    overlay0 = "9ca0b0";
    surface2 = "acb0be";
    surface1 = "bcc0cc";
    surface0 = "ccd0da";
    base = "eff1f5";
    mantle = "e6e9ef";
    crust = "dce0e8";
  };
  colors =
    if theme == "dark"
    then mocha
    else latte;
in
  colors
  // {
    accent = colors.blue;
    # Terminal black and white differ between dark and light flavors.
    black =
      if theme == "dark"
      then colors.surface1
      else colors.subtext1;
    brightBlack =
      if theme == "dark"
      then colors.surface2
      else colors.subtext0;
    white =
      if theme == "dark"
      then colors.subtext1
      else colors.surface2;
    brightWhite =
      if theme == "dark"
      then colors.subtext0
      else colors.surface1;
  }
