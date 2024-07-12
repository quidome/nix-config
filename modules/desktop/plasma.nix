{ config, pkgs, lib, ... }:
with lib;

let
  plasmaEnabled = (config.my.gui == "plasma");
  tailscaleEnabled = config.services.tailscale.enable;
in
{
  config = mkIf plasmaEnabled {
    networking.networkmanager.enable = true;

    # services required for plasma
    services = {
      avahi.enable = true;

      xserver.enable = true;

      desktopManager.plasma6.enable = true;

      displayManager.sddm = {
        enable = true;
        settings.Users = {
          MaximumUid = 99999;
          MinimumUid = 99999;
          RememberLastUser = false;
        };
      };
    };

    # packages to add with kde/plasma
    environment = {
      systemPackages = (with pkgs; [
        aspell
        aspellDicts.en
        aspellDicts.nl
        hunspell
        kompare
        krename
        wl-clipboard

        (mkIf tailscaleEnabled ktailctl)
      ]) ++ (with pkgs.kdePackages; [
        discover
        kcalc
        kcolorchooser
        kgpg
        # kipi-plugins # marked as broken atm
        qttools
      ]);
    };
  };
}
