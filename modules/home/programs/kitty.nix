{
  config,
  lib,
  ...
}: let
  cfg = config.programs.kitty;
  font = config.settings.terminalFont;
in {
  config = lib.mkIf cfg.enable {
    programs.kitty = {
      inherit font;

      themeFile = "gruvbox-dark";
    };
  };
}
