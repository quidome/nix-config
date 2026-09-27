{
  config,
  lib,
  pkgs,
  ...
}: let
  isWorkstation = config.settings.gui != "none";
in {
  config = lib.mkIf isWorkstation {
    hardware.bluetooth.input.General.UserspaceHID = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      adoptopenjdk-icedtea-web
      cameractrls-gtk3
      firefox
      thunderbird
      mani
      obsidian
      spotify
      pandoc
      plantuml
      v4l-utils
      vlc
      vscodium
      wl-clipboard

      # office
      libreoffice-qt
      hunspell
      hunspellDicts.nl_NL
      hunspellDicts.en_US-large
      hunspellDicts.en_GB-large
      element-desktop
      signal-desktop
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    services = {
      avahi = {
        enable = lib.mkDefault true;
        nssmdns4 = lib.mkDefault true;
        openFirewall = lib.mkDefault true;
      };

      flatpak.enable = lib.mkDefault true;
      pipewire.enable = lib.mkDefault true;

      # Enable printing and printer discovery
      printing.enable = lib.mkDefault true;
    };
  };
}
