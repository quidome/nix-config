{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.niri;
in {
  config = mkIf cfg.enable {
    home.file = {
      ".config/niri/config.kdl" = {
        source = config.lib.file.mkOutOfStoreSymlink config.kdl;
      };
    };
  };
}
