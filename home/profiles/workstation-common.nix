{ config, pkgs, lib, ... }:
with lib;
let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinuxWorkstation = (!isDarwin && config.my.gui != "none");
in
{
  config = mkIf (isDarwin || isLinuxWorkstation) {
    my.syncthing.enable = true;

    fonts.fontconfig.enable = true;

    home = {
      packages = with pkgs; [
        bitwarden-cli
        element-desktop
        pandoc
        plantuml
        rcm

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
