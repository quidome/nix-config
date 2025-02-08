{ config, lib, ... }:
let
  cfg = config.settings.profile;
in
{
  config = lib.mkIf cfg.headless { };
}
