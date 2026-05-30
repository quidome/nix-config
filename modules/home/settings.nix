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

        Defaults to GNOME Console on GNOME, konsole on Plasma, and foot on Hyprland.
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
  };

  config.settings.terminal = mkDefault (
    if config.settings.gui == "gnome"
    then "kgx"
    else if config.settings.gui == "hyprland"
    then "foot"
    else "konsole"
  );
}
