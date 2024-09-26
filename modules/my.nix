{ config, lib, ... }:
with lib;
let
  cfg = config.my;
in
{
  options = {
    my.gui = mkOption {
      type = with types; enum [
        "gnome"
        "hyprland"
        "none"
        "pantheon"
        "plasma"
        "sway"
      ];
      default = "none";
      description = ''
        Which gui to use. Gnome or Plasma will install the entire desktop environment. Sway will install the bare minumum. 
        Defaults to `none`, which makes the system headless.
      '';
      example = "sway";
    };

    my.profile.headless = mkEnableOption "headless";
    my.profile.workstation = mkEnableOption "workstation";

    my.wayland.enable = mkEnableOption "wayland";
  };

  config = {
    my.profile.headless = (cfg.gui == "none");
    my.profile.workstation = !cfg.profile.headless;

    my.wayland.enable = builtins.elem cfg.gui [ "gnome" "hyprland" "plasma" "sway" ];
  };
}
