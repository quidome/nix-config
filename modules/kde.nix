{ config, pkgs, lib, ... }:
with lib;

let
  kdeEnabled = config.services.xserver.desktopManager.plasma5.enable;
in
{
  config = mkIf kdeEnabled {
    my.profile = "workstation";
    networking.networkmanager.enable = true;

    # services required for plasma
    services = {
      # avahi.enable = true;
      accounts-daemon.enable = true;

      # run kde on xorg
      xserver.enable = true;

      xserver.displayManager.defaultSession = "plasmawayland";
      xserver.displayManager.sddm.enable = true;
      xserver.displayManager.sddm.settings.Users.RememberLastUser = false;
    };

    programs.dconf.enable = true;
    programs.gnupg.agent.pinentryFlavor = "qt";

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
        libsForQt5.kipi-plugins
        libsForQt5.qt5.qttools
        sddm-kcm
        yakuake

        vlc
      ];
    };
  };
}
