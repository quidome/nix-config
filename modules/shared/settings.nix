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
      type = types.enum ["none" "gnome"];
      default = "gnome";
      description = ''
        Which GUI profile to use.
        Defaults to `gnome`.
      '';
      example = "gnome";
    };

    theme = mkOption {
      type = types.enum ["light" "dark"];
      default = "dark";
      description = "Light or dark theme preference";
      example = "light";
    };

    inputRemapper.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable input-remapper for the desktop user. This is opt-in because the
        service runs as a root-owned system daemon and can inject global input.
      '';
    };

    wallpaper = mkOption {
      type = with types; nullOr str;
      default = null;
      example = "/home/quidome/Pictures/wallpaper.jpg";
      description = "Absolute path to the desktop wallpaper image for graphical sessions.";
    };
  };
}
