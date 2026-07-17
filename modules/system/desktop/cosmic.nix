{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "cosmic") {
    services = {
      desktopManager.cosmic = {
        enable = lib.mkDefault true;
        xwayland.enable = lib.mkDefault true;
      };

      displayManager.cosmic-greeter.enable = lib.mkDefault true;
    };
  };
}
