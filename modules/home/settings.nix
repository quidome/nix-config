{
  config,
  lib,
  ...
}:
with lib; {
  options.settings = {
    theme = mkOption {
      type = types.enum ["light" "dark"];
      default = "dark";
      description = "Light or dark theme preference";
      example = "light";
    };

    wallpaper = mkOption {
      type = with types; nullOr str;
      default = null;
      example = "/home/quidome/Pictures/wallpaper.jpg";
      description = "Absolute path to the desktop wallpaper image for graphical sessions.";
    };

    terminal = mkOption {
      type = types.str;
      example = "ghostty";
      description = lib.mdDoc ''
        Terminal emulator to use across desktop environments.

        Defaults to Ghostty for GNOME and KGX otherwise.
      '';
    };

    terminalMultiplexer = mkOption {
      type = types.enum [
        "zellij"
        "none"
      ];
      default = "zellij";
      description = ''
        Default terminal multiplexer for shells and terminal sessions.
      '';
      example = "zellij";
    };

    terminalFont.name = mkOption {
      default = "JetBrainsMono Nerd Font";
      type = types.str;
      example = "Hack";
      description = "Font name for graphical terminals";
    };

    terminalFont.size = mkOption {
      default = 11;
      type = types.int;
      example = 42;
      description = "Font size for graphical terminals";
    };

    gnome.enableAppIndicator = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GNOME AppIndicator shell extension when available.";
    };
  };

  config = {
    settings.terminal = mkDefault (
      if config.settings.gui == "gnome"
      then "ghostty"
      else "kgx"
    );
  };
}
