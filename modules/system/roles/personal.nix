{
  config,
  lib,
  pkgs,
  zen-browser,
  ...
}: {
  config = lib.mkIf (config.settings.roles.personal.enable && config.settings.gui != "none") {
    environment.systemPackages = with pkgs; [
      cameractrls-gtk3
      firefox
      obsidian
      spotify
      v4l-utils
      vlc
      zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

      # chat
      element-desktop
      signal-desktop

      # office
      libreoffice-qt
      hunspell
      hunspellDicts.nl_NL
      hunspellDicts.en_US-large
      hunspellDicts.en_GB-large
    ];

    services = {
      avahi = {
        enable = lib.mkDefault true;
        nssmdns4 = lib.mkDefault true;
        openFirewall = lib.mkDefault true;
      };

      # Enable printing and printer discovery
      printing.enable = lib.mkDefault true;
    };
  };
}
