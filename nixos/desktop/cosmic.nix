{
  config,
  lib,
  ...
}:
with lib; let
  isCosmic = config.settings.gui == "cosmic";
in {
  config = mkIf isCosmic {
    # Enable the COSMIC login manager
    services.displayManager.cosmic-greeter.enable = true;

    # Enable the COSMIC desktop environment
    services.desktopManager.cosmic.enable = true;

    # Scheduling improvement
    services.system76-scheduler.enable = true;

    programs.firefox = {
      enable = true;
      preferences = {
        # disable libadwaita theming for Firefox
        "widget.gtk.libadwaita-colors.enabled" = false;
      };
    };
  };
}
