{ config, lib, ... }:
let
  hyprlandEnabled = (config.my.gui == "hyprland");
in
{
  config = lib.mkIf hyprlandEnabled {
    services.avizo.enable = true;
  };
}
