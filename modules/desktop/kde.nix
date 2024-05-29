{ config, pkgs, lib, ... }:
with lib;

let
  kdeEnabled = (config.my.gui == "kde");
  tailscaleEnabled = config.services.tailscale.enable;
in
{
  config = mkIf kdeEnabled {
    # services required for plasma
    services = {
      # avahi.enable = true;
      accounts-daemon.enable = true;

      # run kde on xorg
      xserver.enable = true;

      xserver.desktopManager.plasma5.enable = true;

      displayManager.defaultSession = "plasmawayland";

      displayManager.sddm.enable = true;
      displayManager.sddm.settings.Users.RememberLastUser = false;
    };

    programs.dconf.enable = true;
    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;

    # add extra packages to this desktop setup
    environment = {
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
    };
  };
}
