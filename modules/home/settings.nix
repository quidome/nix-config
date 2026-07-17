{
  config,
  lib,
  ...
}:
with lib; {
  options.settings = {
    terminal = mkOption {
      type = types.str;
      example = "ghostty";
      description = lib.mdDoc ''
        Terminal emulator to use across desktop environments.

        Defaults to KGX.
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

  config = {
    settings.terminal = mkDefault (
      if config.settings.gui == "plasma"
      then "konsole"
      else if config.settings.gui == "hyprland"
      then "wezterm"
      else if config.settings.gui == "cosmic"
      then "cosmic-term"
      else "kgx"
    );
  };
}
