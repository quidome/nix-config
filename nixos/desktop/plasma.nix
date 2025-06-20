{ config, pkgs, lib, ... }:
with lib;
let
  plasmaEnabled = (config.settings.gui == "plasma");
  tailscaleEnabled = config.services.tailscale.enable;
in
{
  config = mkIf plasmaEnabled {
    networking.networkmanager.enable = mkDefault true;

    # services required for plasma
    services = {
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
        krename

        (mkIf tailscaleEnabled ktailctl)
      ]) ++ (with pkgs.kdePackages; [
        discover
        kcalc
        kcolorchooser
        kgpg
        kompare
        krdc
        # kipi-plugins # marked as broken atm
        qttools
      ]);
    };

    programs.gnupg.agent.enableSSHSupport = true;
  };
}
