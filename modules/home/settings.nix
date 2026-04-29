{
  config,
  lib,
  ...
}:
with lib; {
  options.settings = {
    terminal = mkOption {
      type = types.str;
      example = "kitty";
      description = lib.mdDoc ''
        Terminal emulator to use across desktop environments.

        Defaults to ghostty on GNOME and konsole on Plasma.
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
  };

  config.settings.terminal = mkDefault (
    if config.settings.gui == "gnome"
    then "ghostty"
    else "konsole"
  );
}
