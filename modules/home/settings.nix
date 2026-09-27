{lib, ...}: {
  options.settings = {
    theme = lib.mkOption {
      type = lib.types.enum ["light" "dark"];
      default = "dark";
      description = "Light or dark theme preference";
      example = "light";
    };
  };
}
