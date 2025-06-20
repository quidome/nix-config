{
  config,
  lib,
  ...
}: let
  cfg = config.services.mako;
in {
  services.mako = lib.mkIf cfg.enable {
    settings = {
      default-timeout = 10000;

      group-by = "summary";
      anchor = "bottom-right";

      font = "JetBrainsMono Nerd Font 11";

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
