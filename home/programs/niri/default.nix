{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.niri;
in {
  options.programs.niri = {
    enable = mkEnableOption "niri";
  };

  config = mkIf cfg.enable {
    home.file = {
      ".config/niri/config.kdl" = {
        source = config.lib.file.mkOutOfStoreSymlink ./config.kdl;
      };
    };
  };
}
