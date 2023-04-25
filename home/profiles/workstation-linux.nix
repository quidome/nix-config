{ config, pkgs, lib, ... }:
with lib;
let isDarwin = pkgs.stdenv.isDarwin;
in
{
  config = mkIf (config.my.profile == "workstation" && !isDarwin) {
    home.packages = with pkgs; [
      adoptopenjdk-icedtea-web
      logseq
      obsidian
      signal-desktop
      spotify
    ];

    programs.firefox.enable = true;
  };
}
