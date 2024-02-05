{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.services.tailscale.enable {
    environment.systemPackages = with pkgs; [ tailscale ];
  };
}
