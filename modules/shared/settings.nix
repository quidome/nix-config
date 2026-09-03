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
      type = types.enum ["plasma" "none"];
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
  };
}
