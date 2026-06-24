{lib, ...}:
with lib; {
  options.settings = {
    terminalMultiplexer = mkOption {
      type = types.enum [
        "tmux"
        "zellij"
        "none"
      ];
      default = "zellij";
      description = ''
        Default terminal multiplexer for shells and terminal sessions.
      '';
      example = "tmux";
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
}
