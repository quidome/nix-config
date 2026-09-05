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
      type = types.enum ["none" "plasma" "gnome"];
      default = "none";
      description = ''
        Which GUI profile to use.
        Defaults to `none`, which makes the system headless.
      '';
      example = "plasma";
    };

    theme = mkOption {
      type = types.enum ["light" "dark"];
      default = "light";
      description = "Light or dark theme preference";
      example = "light";
    };

    wallpaper = mkOption {
      type = with types; nullOr str;
      default = null;
      example = "/home/quidome/Pictures/wallpaper.jpg";
      description = "Absolute path to the desktop wallpaper image for graphical sessions.";
    };
  };
}
