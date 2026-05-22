{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "gnome") {
    environment.systemPackages =
      (with pkgs; [
        gnome-tweaks
        pavucontrol
      ])
      ++ lib.filter (x: x != null) [
        (pkgs.gnomeExtensions.appindicator or null)
        (pkgs.gnomeExtensions.display-configuration-switcher or null)
      ]
      ++ lib.optionals config.services.tailscale.enable (
        lib.filter (x: x != null) [
          (pkgs.gnomeExtensions.tailscale-status or null)
        ]
      );

    services.xserver.enable = lib.mkDefault true;
    services.desktopManager.gnome.enable = lib.mkDefault true;
    services.displayManager.gdm.enable = lib.mkDefault true;

    services.gnome.games.enable = lib.mkDefault false;
    environment.gnome.excludePackages = lib.mkDefault (with pkgs; [
      gnome-tour
      gnome-user-docs
    ]);

  };
}
