{ config, pkgs, lib, ... }:
let
  cfg = config.my.programs.alacritty;
in
{
  options.my.programs.alacritty = {
    enable = lib.mkEnableOption "Enable alacritty";
  };

  config = lib.mkIf cfg.enable {
    programs.alacritty.enable = true;

    # manage config files
    xdg.configFile = {
      "alacritty/alacritty.yml".source = ./alacritty/alacritty.yml;
      "alacritty/monokai.yaml".source = ./alacritty/monokai.yaml;
      "alacritty/tender.yaml".source = ./alacritty/tender.yaml;
    };
  };
}
