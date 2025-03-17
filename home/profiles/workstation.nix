{ config, pkgs, lib, ... }:
let
  cfg = config.settings.profile;
in
{
  config = lib.mkIf cfg.workstation {
    home = {
      packages = with pkgs; [
        (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
      ];
    };

    fonts.fontconfig.enable = true;
    programs.firefox.enable = true;
    services.syncthing.enable = true;
  };
}
