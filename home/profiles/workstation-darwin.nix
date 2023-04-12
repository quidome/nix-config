{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.my.profile == "workstation") {
    home.packages = with pkgs; [
      rectangle
    ];

    home.sessionPath = [
      "/Applications/IntelliJ IDEA.app/Contents/MacOS"
    ];
  };
}
