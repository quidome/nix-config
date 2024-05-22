{ config, pkgs, lib, ... }:
with lib;
let
  gnomeEnabled = (config.my.gui == "gnome");
  tailscaleEnabled = config.services.tailscale.enable;
in
{
  config = mkIf gnomeEnabled {
    # add extra packages to this desktop setup
    environment.systemPackages = (with pkgs; [
      pinentry-gnome
      wl-clipboard
    ]) ++ (with pkgs.gnome; [
      gnome-tweaks
    ]) ++ (with pkgs.gnomeExtensions; [
      appindicator
      (mkIf tailscaleEnabled tailscale-status)
    ]);

    programs.gnupg.agent.pinentryFlavor = "gnome3";

    services.xserver.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  };
}
