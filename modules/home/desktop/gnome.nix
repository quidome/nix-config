{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  gnomeEnabled = config.settings.gui == "gnome";

  inherit (config.settings) terminal;
  isLightTheme = config.settings.theme == "light";
  wallpaper = config.settings.wallpaper;
  gnomeExtensions = pkgs.gnomeExtensions or {};

  terminalCmd =
    if terminal != ""
    then terminal
    else "kgx";
  hasAppIndicator = (gnomeExtensions ? appindicator) && config.settings.gnome.enableAppIndicator;
  hasDisplayConfigurationSwitcher = gnomeExtensions ? display-configuration-switcher;
  gnomeColorScheme =
    if isLightTheme
    then "prefer-light"
    else "prefer-dark";
  gnomeGtkTheme =
    if isLightTheme
    then "Adwaita"
    else "Adwaita Dark";
  wallpaperSettings = lib.optionalAttrs (wallpaper != null) {
    picture-uri = "file://${wallpaper}";
    picture-uri-dark = "file://${wallpaper}";
  };
in {
  config = mkIf gnomeEnabled {
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
    };

    # input-remapper presets for GNOME. EV_REL=2, REL_WHEEL=8,
    # REL_WHEEL_HI_RES=11, EV_KEY=1, BTN_LEFT=272, BTN_RIGHT=273.
    home.file = {
      ".config/input-remapper-2/config.json".text = builtins.toJSON {
        version = "2.2.0";
        autoload = {
          "MOSART Semi. 2.4G Wireless Mouse" = "natural-scroll";
          "Logitech USB Optical Mouse" = "natural-scroll-and-buttons";
        };
      };

      ".config/input-remapper-2/presets/MOSART Semi. 2.4G Wireless Mouse/natural-scroll.json".text = builtins.toJSON [
        {
          input_combination = [
            {
              type = 2;
              code = 8;
            }
          ];
          target_uinput = "mouse";
          output_type = 2;
          output_code = 8;
          gain = -1.0;
        }
        {
          input_combination = [
            {
              type = 2;
              code = 11;
            }
          ];
          target_uinput = "mouse";
          output_type = 2;
          output_code = 11;
          gain = -1.0;
        }
      ];

      # The package autostart runs before USB input devices are always ready.
      ".config/autostart/input-remapper-autoload.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=input-remapper-autoload
        Hidden=true
      '';

      ".config/input-remapper-2/presets/Logitech USB Optical Mouse/natural-scroll-and-buttons.json".text = builtins.toJSON [
        {
          input_combination = [
            {
              type = 1;
              code = 272;
            }
          ];
          target_uinput = "mouse";
          output_symbol = "BTN_RIGHT";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 273;
            }
          ];
          target_uinput = "mouse";
          output_symbol = "BTN_LEFT";
        }
        {
          input_combination = [
            {
              type = 2;
              code = 8;
            }
          ];
          target_uinput = "mouse";
          output_type = 2;
          output_code = 8;
          gain = -1.0;
        }
        {
          input_combination = [
            {
              type = 2;
              code = 11;
            }
          ];
          target_uinput = "mouse";
          output_type = 2;
          output_code = 11;
          gain = -1.0;
        }
      ];
    };

    systemd.user.services.input-remapper-autoload = {
      Unit = {
        Description = "Load input-remapper presets after the graphical session is ready";
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.input-remapper}/bin/input-remapper-control --command stop-all || true; ${pkgs.input-remapper}/bin/input-remapper-control --command autoload'";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions =
          lib.optional hasAppIndicator "appindicatorsupport@rgcjonas.gmail.com"
          ++ lib.optional hasDisplayConfigurationSwitcher "display-configuration-switcher@knokelmaat.gitlab.com";
      };

      "org/gnome/desktop/background" = wallpaperSettings;

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
        # Keep the baseline non-natural; selected mice are inverted by input-remapper.
        natural-scroll = false;
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };

      "org/gnome/desktop/screensaver" = wallpaperSettings;

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
    xsession.preferStatusNotifierItems = lib.mkDefault config.settings.gnome.enableAppIndicator;
  };
}
