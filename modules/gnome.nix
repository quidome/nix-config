{ config, pkgs, lib, ... }:
with lib;
let
  gnomeEnabled = (config.my.gui == "gnome");
in
{
  config = mkIf gnomeEnabled {
    my.profile = "workstation";
    networking.networkmanager.enable = true;

    # use gdm and gnome-shell
    services.xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
      displayManager.gdm.wayland = true;
    };

    programs.gnupg.agent.pinentryFlavor = "gnome3";

    environment.gnome.excludePackages = (with pkgs; [
      gnome-photos
    ]);

    # add extra packages to this desktop setup
    environment.systemPackages = (with pkgs; [
      blackbox-terminal
      guake
      meld
      pinentry-gnome
    ]) ++ (with pkgs.gnome; [
      gnome-terminal
      gnome-tweaks
    ]) ++ (with pkgs.gnomeExtensions; [
      # Add extensions here
      appindicator
      tailscale-status
    ]);
  };
}
