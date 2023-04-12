{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.my.profile == "workstation") {
    home.packages = with pkgs; [
      obsidian
    ];
  }
