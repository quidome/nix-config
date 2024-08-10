{ lib, config, pkgs, ... }:
{
  config = lib.mkIf config.my.wayland.enable {
    environment = {
      sessionVariables.NIXOS_OZONE_WL = "1";
      systemPackages = with pkgs; [
        wl-clipboard
        wofi
      ];
    };
  };
}
