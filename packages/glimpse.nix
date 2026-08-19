{
  autoPatchelfHook,
  fetchurl,
  gtk4,
  gtk4-layer-shell,
  lib,
  libadwaita,
  libheif,
  pam,
  pipewire,
  stdenv,
  zstd,
  ...
}:
stdenv.mkDerivation {
  pname = "glimpse";
  version = "0.15.0";

  src = fetchurl {
    url = "https://github.com/alex-oleshkevich/glimpse/releases/download/v0.15.0/glimpse-0.15.0-x86_64.tar.zst";
    hash = "sha256-CUL4CYJ/fbjRfmACbQ5caLVir5/54LireXbY+TVCZsc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    zstd
  ];

  buildInputs = [
    gtk4
    gtk4-layer-shell
    libadwaita
    libheif
    pam
    pipewire
  ];

  unpackPhase = ''
    tar --zstd -xf "$src"
  '';

  installPhase = ''
    install -Dm755 usr/bin/glimpse-lock $out/bin/glimpse-lock
    install -Dm755 usr/bin/glimpse-shell $out/bin/glimpse-shell
    install -Dm755 usr/bin/glimpse-wallpaper $out/bin/glimpse-wallpaper

    install -Dm755 usr/share/glimpse/scripts/monitors $out/share/glimpse/scripts/monitors
    install -d \
      $out/share/dbus-1/services \
      $out/share/xdg-desktop-portal/portals \
      $out/share/glimpse
    cp -r usr/share/glimpse/themes $out/share/glimpse
    cp -r usr/share/glimpse/applet-templates $out/share/glimpse

    install -d $out/share/systemd/user
    for service in glimpse-lock glimpse-shell glimpse-wallpaper; do
      substitute usr/lib/systemd/user/$service.service \
        $out/share/systemd/user/$service.service \
        --replace-fail /usr/bin/$service $out/bin/$service
    done

    install -Dm644 etc/pam.d/glimpse-lock $out/etc/pam.d/glimpse-lock
    install -Dm644 etc/geoclue/conf.d/glimpse.conf $out/etc/geoclue/conf.d/glimpse.conf
    install -Dm644 usr/share/xdg-desktop-portal/portals/glimpse.portal \
      $out/share/xdg-desktop-portal/portals/glimpse.portal
    substitute usr/share/dbus-1/services/me.aresa.GlimpseIdle.Portal.service \
      $out/share/dbus-1/services/me.aresa.GlimpseIdle.Portal.service \
      --replace-fail /usr/bin/glimpse-shell $out/bin/glimpse-shell

    install -Dm644 LICENSE $out/share/licenses/glimpse/LICENSE
  '';

  meta = {
    description = "Wayland desktop toolkit for Niri";
    homepage = "https://github.com/alex-oleshkevich/glimpse";
    license = lib.licenses.mit;
    mainProgram = "glimpse-shell";
    platforms = ["x86_64-linux"];
  };
}
