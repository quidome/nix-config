{ config, pkgs, lib, ... }:
with lib;

let
  plasma6Enabled = (config.my.gui == "plasma6");
  tailscaleEnabled = config.services.tailscale.enable;
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
      systemPackages = (with pkgs; [
        aspell
        aspellDicts.en
        aspellDicts.nl
        hunspell
        kgpg
        kompare
        krename
        wl-clipboard

        (mkIf tailscaleEnabled tailscale-systray)
      ]) ++ (with pkgs.kdePackages; [
        kcolorchooser
        discover
        # kipi-plugins # marked as broken atm
        qttools
        sddm-kcm
      ]);
    };
  };
}
