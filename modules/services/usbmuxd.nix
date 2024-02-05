{ config, pkgs, lib, ... }:
{
  config = lib.mkIf config.services.usbmuxd.enable
    {
      services.usbmuxd.package = pkgs.usbmuxd2;
      environment.systemPackages = with pkgs; [
        libimobiledevice
              ];
    };
}
