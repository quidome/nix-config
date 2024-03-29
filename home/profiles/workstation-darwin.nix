{ config, pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  config = lib.mkIf (config.my.profile == "workstation" && isDarwin) {
    home.packages = [
    ];
  };
}
