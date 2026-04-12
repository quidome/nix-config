{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  gnomeEnabled = config.settings.gui == "gnome";
  terminal = config.settings.terminal;
  colorScheme =
    if config.settings.theme == "light"
    then "prefer-light"
    else "prefer-dark";
in {
  config = mkIf gnomeEnabled {
    programs.${terminal}.enable = true;
    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = [
          "appindicatorsupport@rgcjonas.gmail.com"
          "display-configuration-switcher@knokelmaat.gitlab.com"
        ];
      };

      "org/gnome/desktop/interface" = {
        color-scheme = colorScheme;
        cursor-theme = "Adwaita";
        enable-hot-corners = false;
        icon-theme = "Adwaita";
        monospace-font-name = "JetBrainsMono Nerd Font Light 11";
      };

      "org/gnome/desktop/peripherals/mouse" = {
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
        command = terminal;
        name = "Launch Terminal";
      };

      "org/gnome/Console".theme = "auto";

      "org/gnome/tweaks".show-extensions-notice = false;
    };

    services.gpg-agent = {
      enableSshSupport = false; # GNOME uses gnome-keyring for SSH
      pinentry.package = pkgs.pinentry-gnome3;
    };
  };
}
