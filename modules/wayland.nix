{ lib, config, pkgs, ... }:
{
  config = lib.mkIf config.my.wayland.enable {
    environment.systemPackages = with pkgs; [
      wl-clipboard
      wofi
    ];
  };
}
