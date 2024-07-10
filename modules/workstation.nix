{ config, lib, ... }:
with lib;
{
  config = mkIf (config.my.gui != "none") {
    services.flatpak.enable = mkDefault true;
    services.openssh.enable = mkDefault true;
    services.pipewire.enable = mkDefault true;
  };
}
