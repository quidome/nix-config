{ config, lib, ... }:
with lib;
{
  options.my = {
    profile = mkOption {
      type = with types; enum [ "none" "workstation" ];
      default = "none";
      description = ''
        Which profile to load. Most common is to use workstation for hosts with a desktop.
        Using `none` will use a headless profile.
      '';
      example = "workstation";
    };
  };
}
