{ lib, config, ... }:
with lib;
let
  cfg = config.my;
in
{
  options.my = {
    syncthing.enable = mkEnableOption "syncthing";

    gui = mkOption {
      type = with types; enum [ "none" "gnome" "hyprland" "pantheon" "plasma" "sway" ];
      default = "none";
      description = ''
        Which gui to use. Gnome or Plasma will install the entire desktop environment. Sway will install the bare minumum. 
        Defaults to `none`, which makes the system headless.
      '';
      example = "sway";
    };

    preferQt = mkEnableOption "qt";
  };

  config = {
    my.preferQt = builtins.elem cfg.gui [ "plasma" "plasma5" ];
  };
}
