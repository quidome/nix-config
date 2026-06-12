{
  config,
  lib,
  ...
}: {
  config =
    lib.mkIf (config.settings.gui == "niri") {
    };
}
