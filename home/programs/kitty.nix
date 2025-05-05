{ config, lib, ... }:
let
  cfg = config.programs.kitty;
in
{
  config = lib.mkIf cfg.enable {
    font.name = "JetBrainsMono Nerd";
    font.size = 12;
  };
}
