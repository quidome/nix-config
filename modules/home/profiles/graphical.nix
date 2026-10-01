{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui != "none") {
    fonts.fontconfig.enable = lib.mkDefault true;
  };
}
