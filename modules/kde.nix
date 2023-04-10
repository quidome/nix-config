{ config, pkgs, lib, ... }:
with lib;

let
  kdeEnabled = config.xserver.desktopManager.plasma5.enable;
in
{
  config = mkIf kdeEnable {
    networking.networkmanager.enable = true;

    # services required for plasma
    services = {
      # avahi.enable = true;
      accounts-daemon.enable = true;

      # run kde on xorg
      xserver.enable = true;

      xserver.displayManager.defaultSession = "plasma";
      xserver.displayManager.sddm.enable = true;
      xserver.displayManager.sddm.settings.Users.RememberLastUser = false;
    };

    programs.dconf.enable = true;
    programs.gnupg.agent.pinentryFlavor = "qt";

    # add extra packages to this desktop setup
    environment = {
      # add some desktop applications
      systemPackages = with pkgs; [
        plasma-pa # needed for managing audio
        # kde apps
        ark
        aspell
        aspellDicts.en
        bluedevil
        gwenview
        hunspell
        kate
        kde-gtk-config
        kdeplasma-addons
        kgpg
        kompare
        krename
        libsForQt5.breeze-gtk
        libsForQt5.dolphin-plugins
        libsForQt5.kcolorchooser
        libsForQt5.kio-extras
        libsForQt5.kipi-plugins
        libsForQt5.plasma-browser-integration
        libsForQt5.plasma-integration
        libsForQt5.qt5.qttools
        libsForQt5.xdg-desktop-portal-kde
        okular
        sddm-kcm
        spectacle
        yakuake

        vlc
      ];
    };
  };
}
