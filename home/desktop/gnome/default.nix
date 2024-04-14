{ config, lib, ... }:
let
  gnomeEnabled = config.my.gui.desktop == "gnome";
in
{
  config = lib.mkIf gnomeEnabled {
    dconf.settings = {
      "/org/gnome/desktop/interface" = {
        cursor-theme = "Adwaita";
        icon-theme = "Adwaita";
      };
    };
  };
}
