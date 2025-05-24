{ lib, config, pkgs, ... }:
{
  config = lib.mkIf config.settings.wayland.enable {
    environment = {
      systemPackages = with pkgs; [
        wl-clipboard
      ];
    };
  };
}
