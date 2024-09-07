{ config, lib, ... }:
with lib;
let
  cfg = config.my;
  isWorkstation = (cfg.gui != "none");
in
{
  options.my = {
    gui = mkOption {
      type = with types; enum [ "none" "cosmic" "gnome" "hyprland" "pantheon" "plasma" "sway" ];
      default = "none";
      description = ''
        Which gui to use. Gnome or Plasma will install the entire desktop environment. Sway will install the bare minumum. 
        Defaults to `none`, which makes the system headless.
      '';
      example = "sway";
    };

    wayland.enable = mkEnableOption "wayland";
  };

  config = {
    my.wayland.enable = builtins.elem cfg.gui [ "cosmic" "gnome" "hyprland" "plasma" "sway" ];
  };
}
