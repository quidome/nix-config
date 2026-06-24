{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "cosmic") {
    services = {
      # Enable the COSMIC login manager
      displayManager.cosmic-greeter.enable = true;

      # Enable the COSMIC desktop environment
      desktopManager.cosmic.enable = true;

      # Use system76 scheduler for better performance
      system76-scheduler.enable = true;
    };
  };
}
