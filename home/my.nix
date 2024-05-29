{ lib, ... }:
with lib;
{
  options.my = {
    syncthing.enable = mkEnableOption "syncthing";

    gui = mkOption {
      type = with types; enum [ "none" "gnome" "plasma5" "sway" "pantheon" "plasma6" ];
      default = "none";
      description = ''
        Which gui to use. Gnome or Plasma will install the entire desktop environment. Sway will install the bare minumum. 
        Defaults to `none`, which makes the system headless.
      '';
      example = "sway";
    };
  };
}
