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

    formFactor = lib.mkOption {
      type = lib.types.enum ["laptop" "desktop" "server"];
      default = "desktop";
      description = ''
        Kind of machine. Controls networking, bluetooth and power management.
        Defaults to `desktop`.
      '';
      example = "laptop";
    };

    roles = {
      dev.enable = lib.mkEnableOption "development and devops tools";
      personal.enable = lib.mkEnableOption "everyday apps, printing and file sync";
      media.enable = lib.mkEnableOption "video editing, 3D modelling and printing tools";
      gaming.enable = lib.mkEnableOption "games";
    };
  };
}
