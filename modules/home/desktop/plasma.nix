{
  config,
  lib,
  ...
}:
with lib; let
  isPlasma = config.settings.gui == "plasma";
  isLight = config.settings.theme == "light";
  useKonsoleLatte = isPlasma && isLight && config.settings.terminal == "konsole";
in {
  config = mkIf isPlasma {
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
    };

    settings.terminal = mkDefault "konsole";

    xdg.dataFile = mkIf useKonsoleLatte {
      "konsole/Catppuccin_Latte.colorscheme".source = ../dotfiles/Catppuccin_Latte.colorscheme;
      "konsole/Catppuccin_Latte.profile".text = ''
        [Appearance]
        ColorScheme=Catppuccin_Latte

        [General]
        Name=Catppuccin Latte
        Parent=FALLBACK/
      '';
    };

    xdg.configFile."konsolerc" = mkIf useKonsoleLatte {
      text = ''
        [Desktop Entry]
        DefaultProfile=Catppuccin_Latte.profile
      '';
    };
  };
}
