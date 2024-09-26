{ config, pkgs, lib, ... }:
let
  cfg = config.my.profile;
in
{
  config = lib.mkIf cfg.workstation {
    fonts.fontconfig.enable = true;

    home = {
      packages = with pkgs; [
        element-desktop
        pandoc
        plantuml

        # office
        (if config.my.preferQt then libreoffice-qt else libreoffice)
        hunspell
        hunspellDicts.nl_NL
        hunspellDicts.en_US-large
        hunspellDicts.en_GB-large
        (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
      ];
    };

    programs.alacritty.enable = true;
    programs.firefox.enable = true;

    services.syncthing.enable = true;
  };
}
