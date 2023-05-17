{ config, pkgs, lib, ... }:
with lib;

let
  gnomeEnabled = config.services.xserver.desktopManager.gnome.enable;
in
{
  config = mkIf gnomeEnabled {
    networking.networkmanager.enable = true;

    # use gdm and gnome-shell
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      displayManager.gdm.wayland = true;
    };

    programs.gnupg.agent.pinentryFlavor = "gnome3";

    environment.gnome.excludePackages = (with pkgs; [
      gnome-photos
    ]) ++ (with pkgs.gnome;[
      geary
    ]);

    # add extra packages to this desktop setup
    environment.systemPackages = (with pkgs; [
      blackbox-terminal
      guake
    ]) ++ (with pkgs.gnome; [
      gnome-terminal
      gnome-tweaks
    ]) ++ (with pkgs.gnomeExtensions; [
      appindicator
      # sound-output-device-chooser
    ]);
  };
}
