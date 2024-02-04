{ lib, ... }:
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

    gui = mkOption {
      type = with types; enum [ "none" "gnome" "kde" "sway" ];
      default = "none";
      description = ''
        Which gui to use. Gnome or KDE will install the entire desktop environment. Sway will install the bare minumum. 
        Defaults to `none`, which makes the system headless.
      '';
      example = "sway";
    };
  };
}
