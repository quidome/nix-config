{
  config,
  lib,
  pkgs,
  ...
}: let
  # Electron does not know niri, so it does not pick gnome-keyring by itself.
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
  inherit (config.settings) gui;
  # Electron picks the right secret store by itself on these desktops.
  knownDesktop = lib.elem gui ["gnome" "plasma"];
in {
  config = lib.mkIf (gui != "none" && !knownDesktop && config.settings.roles.personal.enable) {
    # hiPrio: replace the plain packages from the personal role.
    environment.systemPackages = map lib.hiPrio [signalDesktop elementDesktop];
  };
}
