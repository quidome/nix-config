{ config, pkgs, lib, ... }:
let
  cfg = config.settings.profile;
in
{
  config = lib.mkIf cfg.workstation {
    home = {
      packages = [
        (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];
    };

    fonts.fontconfig.enable = true;
    programs.firefox.enable = true;
    services.syncthing.enable = true;
  };
}
