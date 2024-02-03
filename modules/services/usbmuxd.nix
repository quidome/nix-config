{ config, pkgs, lib, ... }:
{
  config = lib.mkIf config.services.usbmuxd.enable
    {
      environment.systemPackages = with pkgs; [
        libimobiledevice
      ];
    };
}
