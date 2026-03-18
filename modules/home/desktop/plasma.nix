{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  plasmaEnabled = config.settings.gui == "plasma";

  # Catppuccin flavor based on theme setting
  flavor =
    if config.settings.theme == "light"
    then "latte"
    else "mocha";

  # Capitalize first letter helper
  capitalize = str: let
    first = lib.toUpper (lib.substring 0 1 str);
    rest = lib.substring 1 (-1) str;
  in
    first + rest;

  # Build theme names from settings
  flavorCap = capitalize flavor;
  accentCap = capitalize config.settings.catppuccinAccent;

  # Color scheme: "CatppuccinMochaLavender"
  colorScheme = "Catppuccin${flavorCap}${accentCap}";

  # Cursor theme: "catppuccin-mocha-lavender-cursors"
  cursorTheme = "catppuccin-${flavor}-${config.settings.catppuccinAccent}-cursors";

  # Konsole colorscheme
  konsoleColorscheme =
    if config.settings.theme == "light"
    then "Catppuccin-Latte"
    else "Catppuccin-Mocha";
in {
  config = mkIf plasmaEnabled {
    # Catppuccin theme packages
    home.packages = with pkgs; [
      catppuccin-kde
      catppuccin-cursors.${flavor + accentCap}
    ];

    # Plasma-manager configuration
    programs.plasma = {
      enable = true;

      workspace = {
        inherit colorScheme cursorTheme;
        lookAndFeel = "Catppuccin-${flavorCap}-${accentCap}";
      };

      # Konsole profile with Catppuccin
      configFile = {
        "konsolerc"."Desktop Entry"."DefaultProfile" = "Catppuccin.profile";
        "konsolerc"."General"."ConfigVersion" = 1;
      };
    };

    # Catppuccin Konsole colorschemes
    home.file.".local/share/konsole/Catppuccin-Mocha.colorscheme" = {
      enable = true;
      source = ../dotfiles/Catppuccin-Mocha.colorscheme;
    };
    home.file.".local/share/konsole/Catppuccin-Latte.colorscheme" = {
      enable = true;
      source = ../dotfiles/Catppuccin-Latte.colorscheme;
    };

    # Konsole profile using Catppuccin colorscheme
    home.file.".local/share/konsole/Catppuccin.profile".text = ''
      [Appearance]
      ColorScheme=${konsoleColorscheme}
      Font=${config.settings.terminalFont.name},${toString config.settings.terminalFont.size},-1,5,400,0,0,0,0,0,0,0,0,0,0,1

      [General]
      Name=Catppuccin
      Parent=FALLBACK/
    '';

    services.gpg-agent = {
      enableSshSupport = false; # Plasma uses ssh-agent + ksshaskpass + KWallet
      pinentry.package = pkgs.pinentry-qt;
    };
  };
}
