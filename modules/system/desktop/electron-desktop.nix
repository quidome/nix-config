{
  config,
  lib,
  pkgs,
  ...
}: let
  # Electron does not know niri, so it does not pick gnome-keyring by itself.
  # The .desktop files start the program by name, so they get the wrapper too.
  withSecretStore = pkg:
    pkgs.symlinkJoin {
      inherit (pkg) name;
      paths = [pkg];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        rm $out/bin/${pkg.meta.mainProgram}
        makeWrapper ${lib.getExe pkg} $out/bin/${pkg.meta.mainProgram} \
          --add-flags "--password-store=gnome-libsecret"
      '';
    };

  inherit (config.settings) gui;
  # Electron picks the right secret store by itself on these desktops.
  knownDesktop = lib.elem gui ["gnome" "plasma"];
in {
  config = lib.mkIf (gui != "none" && !knownDesktop && config.settings.roles.personal.enable) {
    # hiPrio: replace the plain packages from the personal role.
    environment.systemPackages = map (pkg: lib.hiPrio (withSecretStore pkg)) [
      pkgs.element-desktop
      pkgs.signal-desktop
    ];
  };
}
