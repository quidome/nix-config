{ config, pkgs, lib, ... }:
with lib;
let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinuxWorkstation = (!isDarwin && config.my.gui != "none");
in
{
  config = mkIf isLinuxWorkstation {
    home.packages = with pkgs; [
      adoptopenjdk-icedtea-web
      bitwarden
      go
      logseq
      signal-desktop
      spotify
      vscode

      # office
      (if config.my.preferQt then libreoffice-qt else libreoffice)
      hunspell
      hunspellDicts.nl_NL
      hunspellDicts.en_US-large
      hunspellDicts.en_GB-large
    ];

    programs.firefox.enable = true;
  };
}
