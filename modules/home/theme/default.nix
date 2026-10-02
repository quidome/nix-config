{
  config,
  lib,
  pkgs,
  ...
}: let
  isDark = config.settings.theme == "dark";
  variant =
    if isDark
    then "Dark"
    else "Light";

  uiFont = "Noto Sans";
  monoFont = "JetBrainsMono Nerd Font";
  fontSize = 10;
  iconTheme = "Papirus-${variant}";
  c = import ./palette.nix config.settings.theme;

  # KDE apps read colors, style, icons and fonts from kdeglobals,
  # also outside Plasma.
  kdeFont = name: "${name},${toString fontSize},-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
  kdeglobals =
    builtins.readFile "${pkgs.kdePackages.breeze}/share/color-schemes/Breeze${variant}.colors"
    + lib.generators.toINI {} {
      General = {
        font = kdeFont uiFont;
        fixed = kdeFont monoFont;
        menuFont = kdeFont uiFont;
        smallestReadableFont = kdeFont uiFont;
        toolBarFont = kdeFont uiFont;
      };
      Icons.Theme = iconTheme;
      KDE.widgetStyle = "Breeze";
    };
in {
  # Plasma manages its own theme; this is for sessions without one.
  config = lib.mkIf (config.settings.gui == "niri") {
    home.packages = with pkgs; [
      adwaita-icon-theme
      noto-fonts
    ];

    fonts.fontconfig.defaultFonts = {
      sansSerif = [uiFont];
      monospace = [monoFont];
    };

    home.pointerCursor = {
      enable = true;
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    # Also sets the dark or light preference in dconf, which the portal
    # passes to libadwaita, Firefox and Electron apps.
    gtk = {
      enable = true;
      colorScheme = lib.toLower variant;
      # GTK 4 and libadwaita get the preference from the portal; the
      # settings.ini keys for it give warnings with GTK 4.22.
      gtk4.colorScheme = null;
      font = {
        name = uiFont;
        size = fontSize;
      };
      iconTheme = {
        name = iconTheme;
        package = pkgs.papirus-icon-theme;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "kde";
      style.name = "breeze";
    };

    xdg.configFile."kdeglobals".text = kdeglobals;

    # Catppuccin colors for apps with their own config files.
    programs = {
      alacritty.settings.colors = let
        ansi = {
          black = "#${c.black}";
          red = "#${c.red}";
          green = "#${c.green}";
          yellow = "#${c.yellow}";
          blue = "#${c.blue}";
          magenta = "#${c.pink}";
          cyan = "#${c.teal}";
        };
      in {
        primary = {
          background = "#${c.base}";
          foreground = "#${c.text}";
          dim_foreground = "#${c.overlay1}";
          bright_foreground = "#${c.text}";
        };
        cursor = {
          text = "#${c.base}";
          cursor = "#${c.rosewater}";
        };
        selection = {
          text = "#${c.base}";
          background = "#${c.rosewater}";
        };
        normal = ansi // {white = "#${c.white}";};
        bright =
          ansi
          // {
            black = "#${c.brightBlack}";
            white = "#${c.brightWhite}";
          };
      };

      fuzzel.settings.colors = {
        background = "${c.base}ee";
        text = "${c.text}ff";
        prompt = "${c.subtext1}ff";
        placeholder = "${c.overlay1}ff";
        input = "${c.text}ff";
        match = "${c.accent}ff";
        selection = "${c.surface2}ff";
        selection-text = "${c.text}ff";
        selection-match = "${c.accent}ff";
        counter = "${c.overlay1}ff";
        border = "${c.accent}ff";
      };

      swaylock.settings = {
        color = c.base;
        inside-color = c.base;
        inside-clear-color = c.base;
        inside-ver-color = c.base;
        inside-wrong-color = c.base;
        ring-color = c.surface1;
        ring-clear-color = c.yellow;
        ring-ver-color = c.accent;
        ring-wrong-color = c.red;
        key-hl-color = c.green;
        bs-hl-color = c.red;
        text-color = c.text;
        text-clear-color = c.text;
        text-ver-color = c.text;
        text-wrong-color = c.red;
        line-color = "00000000";
        line-clear-color = "00000000";
        line-ver-color = "00000000";
        line-wrong-color = "00000000";
        separator-color = "00000000";
      };

      waybar.style = ''
        * {
          font-family: "${uiFont}", "${monoFont}";
          font-size: 13px;
          border: none;
          border-radius: 0;
          min-height: 0;
        }
        window#waybar {
          background: #${c.mantle};
          color: #${c.text};
        }
        tooltip {
          background: #${c.base};
          border: 1px solid #${c.surface1};
        }
        #clock, #privacy, #idle_inhibitor, #tray, #wireplumber, #network,
        #bluetooth, #power-profiles-daemon, #battery {
          padding: 0 8px;
        }
        #privacy, #battery.critical:not(.charging) {
          color: #${c.red};
        }
        #idle_inhibitor.activated {
          color: #${c.yellow};
        }
        #battery.warning:not(.charging) {
          color: #${c.peach};
        }
        #battery.charging {
          color: #${c.green};
        }
        #wireplumber.muted, #network.disconnected, #bluetooth.disabled {
          color: #${c.overlay0};
        }
      '';
    };

    services.mako.settings = {
      background-color = "#${c.base}";
      text-color = "#${c.text}";
      border-color = "#${c.accent}";
      progress-color = "over #${c.surface0}";
      "urgency=critical".border-color = "#${c.peach}";
    };
  };
}
