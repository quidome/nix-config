{ config, lib, ... }:
with lib;
let
  isWorkstation = (config.my.gui != "none");
in
{
  config = lib.mkIf isWorkstation {
    services.flatpak.enable = mkDefault true;
    services.pipewire.enable = mkDefault true;

    # Enable printing and printer discovery
    services.printing.enable = mkDefault true;
    services.avahi = {
      enable = mkDefault true;
      nssmdns4 = mkDefault true;
      openFirewall = mkDefault true;
    };
  };
}
