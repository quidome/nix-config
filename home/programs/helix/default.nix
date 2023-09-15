{ lib, config, ... }:
{
  imports = [ ./languages.nix ];
  config.programs.helix = lib.mkIf config.programs.helix.enable {
    settings = {
      theme = "catppuccin_frappe";
    };
  };
}
