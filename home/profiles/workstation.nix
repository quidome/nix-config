{ config, pkgs, lib, ... }:
let
  cfg = config.settings.profile;
in
{
  config = lib.mkIf cfg.workstation {
    fonts.fontconfig.enable = true;

    programs.alacritty.enable = true;
    programs.firefox.enable = true;

    services.syncthing.enable = true;
  };
}
