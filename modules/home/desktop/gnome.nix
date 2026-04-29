{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  gnomeEnabled = config.settings.gui == "gnome";
  terminal = config.settings.terminal;
  isLight = config.settings.theme == "light";
  colorScheme =
    if isLight
    then "prefer-light"
    else "prefer-dark";
  gtkTheme =
    if isLight
    then "Adwaita"
    else "Adwaita Dark";
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
        font-name = "Noto Sans 10";
        document-font-name = "Noto Sans 10";
        gtk-theme = gtkTheme;
        icon-theme = "Adwaita";
        monospace-font-name = "JetBrainsMono Nerd Font Light 11";
      };

      "org/gnome/desktop/input-sources".sources = [
        (lib.hm.gvariant.mkTuple ["xkb" "us"])
      ];

      "org/gnome/desktop/peripherals/mouse" = {
        natural-scroll = true;
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };

      "org/gnome/desktop/sound".theme-name = "ocean";

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "icon:minimize,maximize,close";
        focus-mode = "mouse";
      };

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

    services.gpg-agent.pinentry.package = pkgs.pinentry-gnome3;
  };
}
