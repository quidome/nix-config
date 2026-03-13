{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "gnome") {
    # add extra packages to this desktop setup
    environment.systemPackages =
      (with pkgs; [
        gnome-tweaks
        pavucontrol
      ])
      ++ (with pkgs.gnomeExtensions; [
        appindicator
        (lib.mkIf config.services.tailscale.enable tailscale-status)
      ]);

    services.xserver.enable = lib.mkDefault true;
    services.desktopManager.gnome.enable = lib.mkDefault true;
    services.displayManager.gdm.enable = lib.mkDefault true;

    services.udev.packages = [pkgs.gnome-settings-daemon];
  };
}
