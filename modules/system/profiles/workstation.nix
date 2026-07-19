{
  config,
  lib,
  pkgs,
  zen-browser,
  ...
}:
with lib; let
  isWorkstation = config.settings.gui != "none";
in {
  config = mkIf isWorkstation {
    hardware.bluetooth.input.General.UserspaceHID = mkDefault true;

    environment.systemPackages = with pkgs;
      [
        adoptopenjdk-icedtea-web
        cameractrls-gtk3
        firefox
        mani
        librewolf
        obsidian
        spotify
        pandoc
        pavucontrol
        plantuml
        v4l-utils
        vlc
        vscodium
        wl-clipboard
        zen-browser.packages.x86_64-linux.zen-browser

        # office
        libreoffice-qt
        hunspell
        hunspellDicts.nl_NL
        hunspellDicts.en_US-large
        hunspellDicts.en_GB-large
      ]
      ++ lib.optionals (config.settings.gui != "hyprland") [
        element-desktop
        signal-desktop
      ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    services = {
      avahi = {
        enable = mkDefault true;
        nssmdns4 = mkDefault true;
        openFirewall = mkDefault true;
      };

      flatpak.enable = mkDefault true;
      pipewire.enable = mkDefault true;
      tailscale.enable = mkDefault false;

      # Enable printing and printer discovery
      printing = {
        enable = mkDefault true;
        drivers = with pkgs; [
          cups-filters
          cups-browsed
        ];
      };
    };
  };
}
