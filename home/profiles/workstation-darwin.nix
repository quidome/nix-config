{ config, pkgs, lib, ... }:
with lib;
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  config = mkIf (config.my.profile == "workstation" && isDarwin) {
    home.packages = [
    ];

    programs.alacritty.enable = true;
  };
}
