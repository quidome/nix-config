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

  elementDesktop = pkgs.symlinkJoin {
    name = "element-desktop";
    paths = [pkgs.element-desktop];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      rm $out/bin/element-desktop
      makeWrapper ${lib.getExe pkgs.element-desktop} $out/bin/element-desktop \
        --add-flags "${electronSecretStoreFlags}"

      rm $out/share/applications/element-desktop.desktop
      cp ${pkgs.element-desktop}/share/applications/element-desktop.desktop $out/share/applications/element-desktop.desktop
      substituteInPlace $out/share/applications/element-desktop.desktop \
        --replace-fail "Exec=element-desktop %u" "Exec=element-desktop ${electronSecretStoreFlags} %u"
    '';
  };
in {
  config = lib.mkIf (lib.elem config.settings.gui ["hyprland" "niri"]) {
    environment.systemPackages = [signalDesktop elementDesktop];
  };
}
