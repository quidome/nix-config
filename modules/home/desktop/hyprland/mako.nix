{
  config,
  lib,
}: let
  font = config.settings.terminalFont;
in {
  enable = lib.mkDefault true;

  settings = {
    default-timeout = 10000;
    group-by = "summary";
    anchor = "bottom-right";
    font = "${font.name} ${toString font.size}";
    border-radius = 5;
    margin = "2,2";

    grouped.format = "<b>%s</b>\\n%bd";
  };
}
