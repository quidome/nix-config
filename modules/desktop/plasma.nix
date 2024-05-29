{ config, pkgs, lib, ... }:
with lib;

let
  plasmaEnabled = (config.my.gui == "plasma");
  # tailscaleEnabled = config.services.tailscale.enable;
in
{
  config = mkIf plasmaEnabled {
    # services required for plasma
    services = {
      # avahi.enable = true;
      #       accounts-daemon.enable = true;

      # run kde on xorg
      xserver.enable = true;

      desktopManager.plasma6.enable = true;

      # displayManager.defaultSession = "plasma";

      displayManager.sddm.enable = true;
      displayManager.sddm.settings.Users.RememberLastUser = false;
    };

    #     programs.dconf.enable = true;
    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;

    # add extra packages to this desktop setup
    /*    environment = {
      # add some desktop applications
      systemPackages = with pkgs; [
        ark
        aspell
        aspellDicts.en
        hunspell
        kate
        kgpg
        kompare
        krename
        libsForQt5.kcolorchooser
        libsForQt5.discover
        libsForQt5.kipi-plugins
        libsForQt5.qt5.qttools
        sddm-kcm
        wl-clipboard
        yakuake

        (mkIf tailscaleEnabled tailscale-systray)
      ];
    */
    # };
  };
}
