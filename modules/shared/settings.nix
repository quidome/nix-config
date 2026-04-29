{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.settings;
in {
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
          "plasma"
        ];
      default = "none";
      description = ''
        Which gui to use. Plasma installs the desktop environment.
        Defaults to `none`, which makes the system headless.
      '';
      example = "plasma";
    };

    preferQt = mkOption {
      default = false;
      description = ''
        Whether to prefer QT toolkit over GTK.

        Influences things like which version of libre office to install.
      '';
      type = types.bool;
    };

    theme = mkOption {
      type = types.enum ["light" "dark"];
      default = "dark";
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

  #############################################################################
  # CONFIGURATION
  #############################################################################
  config = {
    settings = {
      preferQt = builtins.elem cfg.gui ["plasma"];
    };
  };
}
