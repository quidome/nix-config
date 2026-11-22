{
  config,
  lib,
  ...
}: let
  plasmaEnabled = config.settings.gui == "plasma";

  # Only the color scheme: a full look-and-feel package also resets the panel layout.
  colorScheme =
    if config.settings.theme == "light"
    then "BreezeLight"
    else "BreezeDark";
in {
  config = lib.mkIf plasmaEnabled {
    programs.plasma = {
      enable = true;
      workspace.colorScheme = colorScheme;
      configFile.kdeglobals.KDE.AnimationDurationFactor = 0.25;
    };
  };
}
