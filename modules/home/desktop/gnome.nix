{
  config,
  lib,
  pkgs,
  ...
}: let
  gnomeEnabled = config.settings.gui == "gnome";

  isLightTheme = config.settings.theme == "light";
  gnomeColorScheme =
    if isLightTheme
    then "prefer-light"
    else "prefer-dark";
  gnomeGtkTheme =
    if isLightTheme
    then "Adwaita"
    else "Adwaita Dark";
in {
  config = lib.mkIf gnomeEnabled {
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.ghostty.enable = lib.mkDefault true;

    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = [
          "caffeine@patapon.info"
          "display-configuration-switcher@knokelmaat.gitlab.com"
        ];
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
        left-handed = true;
        natural-scroll = true;
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        natural-scroll = true;
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
        command = "ghostty";
        name = "Launch Terminal";
      };

      "org/gnome/Console".theme = "auto";

      "org/gnome/tweaks".show-extensions-notice = false;
    };

    services.gpg-agent.pinentry.package = pkgs.pinentry-gnome3;
  };
}
