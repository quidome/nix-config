{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.services.usbmuxd.enable {
    environment.systemPackages = [ pkgs.libimobiledevice ];
    services.usbmuxd.package = pkgs.usbmuxd2;
  };
}
