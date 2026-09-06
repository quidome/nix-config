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
  };

  config = {
    settings.terminal = mkDefault (
      if config.settings.gui == "gnome"
      then "ghostty"
      else "kgx"
    );
  };
}
