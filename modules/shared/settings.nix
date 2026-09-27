{lib, ...}: {
  #############################################################################
  # OPTIONS
  #############################################################################
  options.settings = {
    authorizedKeys = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
      example = [
        "ssh-ed25519 AAAAC3 ....."
        "ssh-ed25519 AAAAC3 ....."
      ];
      description = "Specify public ssh keys to allow access to hosts.";
    };

    gui = lib.mkOption {
      type = lib.types.enum ["none" "plasma"];
      default = "plasma";
      description = ''
        Which GUI profile to use.
        Defaults to `plasma`.
      '';
      example = "plasma";
    };
  };
}
