{ config, lib, ... }:
let
  cfg = config.services.mako;
in
{
  services.mako = lib.mkIf cfg.enable {
    anchor = "bottom-right";
    defaultTimeout = 10000;

    font = "JetBrainsMono Nerd Font 11";

    borderRadius = 5;
    backgroundColor = "#282828ff";
    borderColor = "#161616ff";
    textColor = "#a1a1a1";

    margin = "2,2";

    groupBy = "summary";
    extraConfig = ''
      [grouped]
      format=<b>%s</b>\n%b
    '';
  };
}
