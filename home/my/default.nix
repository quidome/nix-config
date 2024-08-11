{ lib, config, ... }:
with lib;
let
  cfg = config.my;
in
{
  imports = [
    ./wayland.nix
    ./xdg.nix
  ];

  options.my = {
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
    syncthing.enable = mkEnableOption "syncthing";
    wayland.enable = mkEnableOption "wayland";
  };

  config = {
    my.preferQt = builtins.elem cfg.gui [ "hyprland" "plasma" "sway" ];
    my.wayland.enable = builtins.elem cfg.gui [ "gnome" "hyprland" "plasma" "sway" ];
  };
}
