{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.noctalia;
in {
  options.programs.noctalia = {
    enable = mkEnableOption "noctalia";
  };

  config = mkIf cfg.enable {
    home.file = {
      ".config/noctalia/colors.json" = {
        source = config.lib.file.mkOutOfStoreSymlink ./colors.json;
      };
      ".config/noctalia/settings-generated.json" = {
        source = config.lib.file.mkOutOfStoreSymlink ./settings.json;
      };
    };
  };
}
