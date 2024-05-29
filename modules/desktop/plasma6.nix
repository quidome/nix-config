{ config, pkgs, lib, ... }:
with lib;

let
  plasma6Enabled = (config.my.gui == "plasma6");
  # tailscaleEnabled = config.services.tailscale.enable;
in
{
  config = mkIf plasma6Enabled {
    # services required for plasma
    services = {
      avahi.enable = true;

      xserver.enable = true;

      desktopManager.plasma6.enable = true;

      displayManager.sddm.enable = true;
      displayManager.sddm.settings.Users.RememberLastUser = false;
    };

    programs.dconf.enable = true;

    # packages to add with kde/plasma
    environment = {
      systemPackages = with pkgs; [
        aspell
        aspellDicts.en
        hunspell
        kgpg
        kompare
        krename
        libsForQt5.kcolorchooser
        libsForQt5.discover
        libsForQt5.kipi-plugins
        libsForQt5.qt5.qttools
        sddm-kcm
        wl-clipboard

        (mkIf tailscaleEnabled tailscale-systray)
      ];
    };
  };
}
