{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.settings.gui == "gnome") {
    # add extra packages to this desktop setup
    environment.systemPackages = (with pkgs; [
      gnome-tweaks
      pavucontrol
      # ]) ++ (with pkgs.gnome; [
    ]) ++ (with pkgs.gnomeExtensions; [
      appindicator
      # sound-output-device-chooser
      (lib.mkIf config.services.tailscale.enable tailscale-status)
    ]);

    services.xserver.enable = lib.mkDefault true;
    services.xserver.desktopManager.gnome.enable = lib.mkDefault true;
    services.xserver.displayManager.gdm.enable = lib.mkDefault true;

    services.udev.packages = [ pkgs.gnome-settings-daemon ];
  };
}
