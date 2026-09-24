{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "gnome") {
    environment.systemPackages = with pkgs; [
      geary
      gnome-tweaks
      ghostty
      pavucontrol
      gnomeExtensions.caffeine
      gnomeExtensions.display-configuration-switcher
    ];

    services = {
      xserver.enable = lib.mkDefault true;
      desktopManager.gnome.enable = lib.mkDefault true;
      displayManager.gdm.enable = lib.mkDefault true;
    };
  };
}
