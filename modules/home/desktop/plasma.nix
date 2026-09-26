{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "plasma") {
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
