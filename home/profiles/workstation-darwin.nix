{ config, pkgs, lib, ... }:
with lib;
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  config = mkIf (config.my.profile == "workstation" && isDarwin) {
    home.packages = with pkgs; [
      rectangle
    ];

    home.sessionPath = [
      "/Applications/IntelliJ IDEA.app/Contents/MacOS"
    ];
  };
}
