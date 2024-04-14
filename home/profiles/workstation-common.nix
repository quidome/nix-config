{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.my.profile == "workstation") {
    my.syncthing.enable = true;

    fonts.fontconfig.enable = true;

    home = {
      packages = with pkgs; [
        bitwarden-cli
        discord
        element-desktop
        gimp
        pandoc
        plantuml
        rcm

        # office
        libreoffice-qt
        hunspell
        hunspellDicts.nl_NL
        hunspellDicts.en_US-large
        hunspellDicts.en_GB-large

        (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
      ];

      sessionPath = [
        "${config.home.homeDirectory}/bin"
        "${config.home.homeDirectory}/go/bin"
        "${config.home.homeDirectory}/.cargo/bin"
      ];

      sessionVariables = {
        DEV_PATH = "${config.home.homeDirectory}/dev";
      };
    };
  };
}
