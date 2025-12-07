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
          "cosmic"
          "gnome"
          "hyprland"
          "plasma"
          "sway"
        ];
      default = "none";
      description = ''
        Which gui to use. Gnome or Plasma will install the entire desktop environment. Sway will install the bare minumum.
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
  };

  #############################################################################
  # CONFIGURATION
  #############################################################################
  config.settings = {
    preferQt = builtins.elem cfg.gui ["plasma"];
  };
}
