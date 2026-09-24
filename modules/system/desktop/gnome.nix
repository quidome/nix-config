{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "gnome") {
    environment.systemPackages =
      (with pkgs; [
        geary
        gnome-tweaks
        ghostty
        pavucontrol
      ])
      ++ lib.filter (x: x != null) [
        (pkgs.gnomeExtensions.caffeine or null)
        (pkgs.gnomeExtensions.display-configuration-switcher or null)
      ];

    services = {
      xserver.enable = lib.mkDefault true;
      desktopManager.gnome.enable = lib.mkDefault true;
      displayManager.gdm.enable = lib.mkDefault true;
    };
  };
}
