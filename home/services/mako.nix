{
  config,
  lib,
  ...
}: let
  cfg = config.services.mako;
  font = config.settings.terminalFont;
in {
  services.mako = lib.mkIf cfg.enable {
    settings = {
      default-timeout = 10000;

      group-by = "summary";
      anchor = "bottom-right";

      font = "${font.name} ${toString font.size}";

      border-radius = 5;
      background-color = "#282828ff";
      border-color = "#161616ff";
      text-color = "#a1a1a1";

      margin = "2,2";

      grouped = {
        format = "<b>%s</b>\\n%bd";
      };
    };
  };
}
