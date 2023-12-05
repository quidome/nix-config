{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.my.profile == "workstation") {
    services.flatpak.enable = true;
    services.openssh.enable = true;
    services.pipewire.enable = true;
  };
}
