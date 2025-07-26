{lib, ...}:
with lib; {
  options.settings = {
    terminalFont.name = mkOption {
      default = "Hack";
      type = types.str;
      example = "Hack";
      description = "Font name for graphical terminals";
    };

    terminalFont.size = mkOption {
      default = 12;
      type = types.int;
      example = 42;
      description = "Font size for graphical terminals";
    };
  };
}
