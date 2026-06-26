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
          "hyprland"
        ];
      default = "hyprland";
      description = ''
        Which GUI profile to use.
        Defaults to `hyprland`.
      '';
      example = "hyprland";
    };

    theme = mkOption {
      type = types.enum ["light" "dark"];
      default = "dark";
      description = "Light or dark theme preference";
      example = "dark";
    };
  };
}
