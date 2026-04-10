{
  config,
  lib,
  ...
}:
with lib; {
  options.laptop.enable = mkOption {
    default = false;
    type = types.bool;
    description = "Whether this host is a laptop. Enables laptop-specific power management.";
  };

  config = mkIf config.laptop.enable {
    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };
  };
}
