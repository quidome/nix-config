{ config, lib, pkgs, ... }:
with lib;
with pkgs;
{
  config = mkIf config.services.tailscale.enable {
    environment.systemPackages =
      [ tailscale ];
  };
}
