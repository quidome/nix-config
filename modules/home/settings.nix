{
  config,
  lib,
  ...
}:
with lib; {
  options.settings = {
    terminal = mkOption {
      type = types.str;
      example = "konsole";
      description = lib.mdDoc ''
        Terminal emulator to use across desktop environments.

        Defaults to konsole on Plasma and Ghostty otherwise.
      '';
    };

    terminalFont.name = mkOption {
      default = "JetBrains Mono Nerd Font";
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

    niri.defaultColumnWidth = mkOption {
      type = types.number;
      default = 1.0;
      example = 0.3333;
      description = "Default width for new Niri columns as a fraction of available width.";
    };
  };

  config.settings.terminal = mkDefault (
    if config.settings.gui == "plasma"
    then "konsole"
    else "ghostty"
  );
}
