{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "gnome") {
    programs.zellij.settings.copy_command = "wl-copy";
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        cursor-theme = "Adwaita";
        enable-hot-corners = false;
        icon-theme = "Adwaita";
        monospace-font-name = "JetBrainsMono Nerd Font Light 11";
      };

      "org/gnome/desktop/peripherals/mouse" = {
        left-handed = true;
        natural-scroll = true;
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };

      "org/gnome/desktop/wm/preferences".focus-mode = "mouse";

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>Return";
        command = lib.getExe pkgs.gnome-console;
        name = "Launch Terminal";
      };

      "org/gnome/tweaks".show-extensions-notice = false;
    };

    services.gpg-agent = {
      enableSshSupport = false;
      pinentry.package = pkgs.pinentry-gnome3;
    };
  };
}
