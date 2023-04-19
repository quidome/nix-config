{ config, pkgs, lib, ... }:
with lib;

let
  cfg = config.my.gui;
  gnomeEnabled = config.services.xserver.desktopManager.gnome.enable;
in
{
  config = mkIf gnomeEnabled {
    my.gui.wayland.enable = true;
    networking.networkmanager.enable = true;

    # use gdm and gnome-shell
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      displayManager.gdm.wayland = cfg.wayland.enable;
    };

    programs.gnupg.agent.pinentryFlavor = "gnome3";

    # add extra packages to this desktop setup
    environment = {
      # add some desktop applications
      systemPackages = with pkgs; [
        gnome3.gnome-tweaks
        guake

        gnomeExtensions.appindicator
        gnomeExtensions.sound-output-device-chooser
      ];
    };
  };
}
