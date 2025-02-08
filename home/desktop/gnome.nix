{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.settings.gui == "gnome") {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        cursor-theme = "Adwaita";
        icon-theme = "Adwaita";
      };

      "plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>Return";
        command = lib.getExe pkgs.alacritty;
        name = "Launch Terminal";
      };
    };

    services.gpg-agent = {
      enableSshSupport = false;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };
}
