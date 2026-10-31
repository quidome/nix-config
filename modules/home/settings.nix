{lib, ...}: {
  options.settings = {
    theme = lib.mkOption {
      type = lib.types.enum ["light" "dark"];
      default = "dark";
      description = "Light or dark theme preference";
      example = "light";
    };

    monoFont = lib.mkOption {
      type = lib.types.str;
      default = "JetBrainsMono Nerd Font";
      description = "Monospace font for terminals, editors and the theme";
    };
  };
}
