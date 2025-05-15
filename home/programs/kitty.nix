{ config, lib, ... }:
let
  cfg = config.programs.kitty;
in
{
  config = lib.mkIf cfg.enable {
    programs.kitty = {
      font.name = "JetBrainsMono Nerd Font";
      font.size = 11;

      themeFile = "gruvbox-dark";
    };
  };
}
