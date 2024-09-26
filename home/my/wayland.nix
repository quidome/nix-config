{ config, lib, ... }:
let
  cfg = config.my.wayland;
in
{
  config = lib.mkIf cfg.enable {
    programs.wofi.enable = true;
  };
}
