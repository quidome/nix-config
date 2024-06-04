{ config, lib, ... }:
with lib;
{
  config = mkIf (config.my.gui != "none") {
    # Install and configure flatpak
    services.flatpak.enable = true;
    services.openssh.enable = mkDefault true;
    services.pipewire.enable = mkDefault true;
  };
}
