{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "plasma") {
    environment.systemPackages =
      (with pkgs; [
        krename
      ])
      ++ (with pkgs.kdePackages; [
        discover
        kcalc
        kcolorchooser
        kompare
        krdc
      ]);

    services = {
      desktopManager.plasma6.enable = lib.mkDefault true;

      displayManager.sddm = {
        enable = lib.mkDefault true;
        wayland.enable = lib.mkDefault true;
        # Do not list or remember users on the login screen.
        settings = {
          General.RememberLastSession = false;
          Users = {
            MinimumUid = 2147483647;
            MaximumUid = 2147483647;
            RememberLastUser = false;
          };
        };
      };
    };
  };
}
