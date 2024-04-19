{ lib, ... }:
with lib;
{
  options.my = {
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
