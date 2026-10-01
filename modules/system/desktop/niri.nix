{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "niri") {
    programs.niri.enable = lib.mkDefault true;
  };
}
