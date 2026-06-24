{lib, ...}:
with lib; {
  #############################################################################
  # OPTIONS
  #############################################################################
  options.settings = {
    authorizedKeys = mkOption {
      default = [];
      type = types.listOf types.str;
      example = [
        "ssh-ed25519 AAAAC3 ....."
        "ssh-ed25519 AAAAC3 ....."
      ];
      description = "Specify public ssh keys to allow access to hosts.";
    };

    gui = mkOption {
      type = with types;
        enum [
          "none"
          "cosmic"
        ];
      default = "cosmic";
      description = ''
        Which gui to use. COSMIC installs the full desktop environment.
        Use `none` to make the system headless.
      '';
      example = "cosmic";
    };

    theme = mkOption {
      type = types.enum ["light" "dark"];
      default = "light";
      description = ''
        Which color theme to use. Maps to catppuccin flavors:
        - light -> latte
        - dark -> mocha
      '';
      example = "light";
    };

    catppuccinAccent = mkOption {
      type = types.enum [
        "blue"
        "flamingo"
        "green"
        "lavender"
        "maroon"
        "mauve"
        "peach"
        "pink"
        "red"
        "rosewater"
        "sapphire"
        "sky"
        "teal"
        "yellow"
      ];
      default = "lavender";
      description = "Accent color for catppuccin theme.";
      example = "blue";
    };
  };
}
