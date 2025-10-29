{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "cosmic") {
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic.enable = true;
  };
}
