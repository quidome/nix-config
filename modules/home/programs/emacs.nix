{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.programs.emacs;
in {
  config = lib.mkIf cfg.enable {
    programs.emacs = {
      package = pkgs.emacs;
      extraPackages = epkgs: with epkgs; [
        vterm
        # Add other Emacs packages here as needed
      ];
    };
  };
}
