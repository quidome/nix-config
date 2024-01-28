{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.my.profile == "workstation") {
    # Install and configure flatpak
    system.activationScripts = {
      flathub = ''
        /run/current-system/sw/bin/flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };

    environment.systemPackages = with pkgs; [
      tailscale
    ];

    services.flatpak.enable = true;
    services.openssh.enable = true;
    services.pipewire.enable = true;
    services.tailscale.enable = true;
  };
}
