{ config, lib, ... }:
let
  cfg = config.services.kanshi;
in
{
  services.kanshi = lib.mkIf cfg.enable {
    systemdTarget = "graphical-session.target";
  };
}
