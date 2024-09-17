{ config, lib, pkgs, ... }:
with lib;
let
  isWorkstation = (config.my.gui != "none");
in
{
  config = lib.mkIf isWorkstation {
    environment.systemPackages = with pkgs; [
      adoptopenjdk-icedtea-web
      bitwarden
      obsidian
      logseq
      signal-desktop
      spotify
      thunderbird
      vscode
    ];

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
