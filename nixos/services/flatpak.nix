{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.flatpak;
in {
  config = lib.mkIf cfg.enable {
    users.groups.flatpak = {};

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id === "org.freedesktop.Flatpak.app-install" ||
             action.id === "org.freedesktop.Flatpak.runtime-install" ||
             action.id === "org.freedesktop.Flatpak.app-uninstall" ||
             action.id === "org.freedesktop.Flatpak.runtime-uninstall") &&
            subject.isInGroup("flatpak")) {
          return polkit.Result.YES;
        }
      });
    '';

    systemd.services.flatpak-repo = {
      wantedBy = ["multi-user.target"];
      path = [pkgs.flatpak];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
