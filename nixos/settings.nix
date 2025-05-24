{ lib, ... }:
with lib;
{
  options.settings = {
    authorizedKeys = mkOption {
      default = [ ];
      type = types.listOf types.str;
      example = [
        "ssh-ed25519 AAAAC3 ....."
        "ssh-ed25519 AAAAC3 ....."
      ];
      description = "Specify public ssh keys to allow access to hosts.";
    };
  };
}
