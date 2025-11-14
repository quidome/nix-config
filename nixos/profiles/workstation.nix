{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.settings.profile;
in {
  config = mkIf cfg.workstation {
    environment.systemPackages = with pkgs; [
      adoptopenjdk-icedtea-web
      bitwarden
      cameractrls-gtk3
      discord
      element-desktop
      emacs
      firefox
      logseq
      obsidian
      pandoc
      plantuml
      signal-desktop
      spotify
      thunderbird
      v4l-utils
      vlc
      vscode

      openttd

      # office
      (
        if config.settings.preferQt
        then libreoffice-qt
        else libreoffice
      )
      hunspell
      hunspellDicts.nl_NL
      hunspellDicts.en_US-large
      hunspellDicts.en_GB-large
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.roboto-mono
    ];

    services.flatpak.enable = mkDefault true;
    services.pipewire.enable = mkDefault true;
    services.tailscale.enable = mkDefault false;

    # Enable printing and printer discovery
    services.printing.enable = mkDefault true;
    services.printing.drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
    services.avahi = {
      enable = mkDefault true;
      nssmdns4 = mkDefault true;
      openFirewall = mkDefault true;
    };
  };
}
