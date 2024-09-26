{ config, lib, ... }:
let
  cfg = config.my.profile;
in
{
  config = lib.mkIf cfg.headless { };
}
