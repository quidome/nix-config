{
  config,
  lib,
  pkgs,
  ...
}: let
  electronSecretStoreFlags = "--password-store=gnome-libsecret";

  signalDesktop = pkgs.symlinkJoin {
    name = "signal-desktop";
    paths = [pkgs.signal-desktop];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      rm $out/bin/signal-desktop
      makeWrapper ${lib.getExe pkgs.signal-desktop} $out/bin/signal-desktop \
        --add-flags "${electronSecretStoreFlags}"

      rm $out/share/applications/signal.desktop
      cp ${pkgs.signal-desktop}/share/applications/signal.desktop $out/share/applications/signal.desktop
      substituteInPlace $out/share/applications/signal.desktop \
        --replace-fail "Exec=signal-desktop %U" "Exec=signal-desktop ${electronSecretStoreFlags} %U"
    '';
  };
in {
  config = lib.mkIf (lib.elem config.settings.gui ["hyprland" "niri"]) {
    environment.systemPackages = [signalDesktop];
  };
}
