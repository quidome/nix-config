{ config, lib, ... }:
{
  config = lib.mkIf (config.my.gui == "gnome") {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        cursor-theme = "Adwaita";
        icon-theme = "Adwaita";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>Return";
        command = "alacritty";
        name = "Launch Alacritty";
      };
    };

    programs.zellij.settings.copy_command = "wl-copy";
  };
}
