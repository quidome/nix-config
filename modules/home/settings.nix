{lib, ...}:
with lib; {
  options.settings = {
    theme = mkOption {
      type = types.enum ["light" "dark"];
      default = "dark";
      description = "Light or dark theme preference";
      example = "light";
    };
  };
}
