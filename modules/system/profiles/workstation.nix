{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  isWorkstation = config.settings.gui != "none";
in {
  config = mkIf isWorkstation {
    hardware.bluetooth.input.General.UserspaceHID = mkDefault true;

    environment.systemPackages = with pkgs; [
      adoptopenjdk-icedtea-web
      cameractrls-gtk3
      firefox
      mani
      mpv
      element-desktop
      obsidian
      signal-desktop
      spotify
      pandoc
      pavucontrol
      plantuml
      v4l-utils
      vlc
      vscodium
      wl-clipboard

      openttd

      # office
      libreoffice
      hunspell
      hunspellDicts.nl_NL
      hunspellDicts.en_US-large
      hunspellDicts.en_GB-large
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.roboto-mono
      noto-fonts
    ];

    services = {
      flatpak.enable = mkDefault true;
      pipewire.enable = mkDefault true;
      tailscale.enable = mkDefault false;

      # Enable printing and printer discovery
      printing.enable = mkDefault true;
      printing.drivers = with pkgs; [
        cups-filters
        cups-browsed
      ];
      avahi = {
        enable = mkDefault true;
        nssmdns4 = mkDefault true;
        openFirewall = mkDefault true;
      };
    };
  };
}
