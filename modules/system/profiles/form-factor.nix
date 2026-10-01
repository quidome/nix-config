{
  config,
  lib,
  ...
}: let
  inherit (config.settings) formFactor;
in {
  config = lib.mkMerge [
    (lib.mkIf (formFactor != "server") {
      networking.networkmanager.enable = lib.mkDefault true;

      hardware.bluetooth = {
        enable = lib.mkDefault true;
        powerOnBoot = lib.mkDefault true;
      };
    })

    (lib.mkIf (formFactor == "laptop") {
      services = {
        fwupd.enable = lib.mkDefault true;
        power-profiles-daemon.enable = lib.mkDefault true;
        upower.enable = lib.mkDefault true;
      };
    })
  ];
}
