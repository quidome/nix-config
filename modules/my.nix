{ config, lib, ... }:
with lib;
let
  isWorkstation = (config.my.gui != "none");
in
{
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
  };

  config = mkIf isWorkstation {
    services.flatpak.enable = mkDefault true;
    services.pipewire.enable = mkDefault true;
  };
}
