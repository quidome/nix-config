{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  gnomeEnabled = config.settings.gui == "gnome";

  terminal = config.settings.terminal;
  isLightTheme = config.settings.theme == "light";
  gnomeExtensions = pkgs.gnomeExtensions or {};

  terminalCmd =
    if terminal != ""
    then terminal
    else "kgx";
  hasAppIndicator = gnomeExtensions ? appindicator;
  hasDisplayConfigurationSwitcher = gnomeExtensions ? display-configuration-switcher;
  gnomeColorScheme =
    if isLightTheme
    then "prefer-light"
    else "prefer-dark";
  gnomeGtkTheme =
    if isLightTheme
    then "Adwaita"
    else "Adwaita Dark";
in {
  config = mkIf gnomeEnabled {
    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions =
          lib.optional hasAppIndicator "appindicatorsupport@rgcjonas.gmail.com"
          ++ lib.optional hasDisplayConfigurationSwitcher "display-configuration-switcher@knokelmaat.gitlab.com";
      };

      "org/gnome/desktop/interface" = {
        color-scheme = gnomeColorScheme;
        cursor-theme = "Adwaita";
        enable-hot-corners = false;
        font-name = "Noto Sans 10";
        document-font-name = "Noto Sans 10";
        gtk-theme = gnomeGtkTheme;
        icon-theme = "Adwaita";
        monospace-font-name = "monospace 11";
      };

      "org/gnome/desktop/sound".theme-name = "ocean";

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

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "icon:minimize,maximize,close";
        # Follow pointer focus behavior intentionally.
        focus-mode = "mouse";
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>Return";
        command = terminalCmd;
        name = "Launch Terminal";
      };

      "org/gnome/Console".theme = "auto";

      "org/gnome/tweaks".show-extensions-notice = false;
    };

    services.gpg-agent.pinentry.package = pkgs.pinentry-gnome3;
  };
}
