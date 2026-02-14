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

        Defaults to wezterm for most desktops, but uses ghostty
        for niri due to compatibility issues.
      '';
    };

    terminalFont.name = mkOption {
      default = "Hack";
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
    if config.settings.gui == "niri"
    then "ghostty"
    else "wezterm"
  );
}
