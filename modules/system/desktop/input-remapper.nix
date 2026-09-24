{
  config,
  pkgs,
  lib,
  desktopUser,
  ...
}: let
  inputRemapperDbusPolicy = pkgs.writeText "inputremapper.Control.conf" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN"
    "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
    <busconfig>
      <!-- The daemon is root-owned; only the configured desktop user may control it. -->
      <policy user="root">
        <allow own="inputremapper.Control"/>
        <allow send_destination="inputremapper.Control"/>
      </policy>
      <policy user="${lib.escapeXML desktopUser}">
        <allow send_destination="inputremapper.Control"/>
      </policy>
    </busconfig>
  '';
  inputRemapperPackage = pkgs.input-remapper.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        install -Dm644 ${inputRemapperDbusPolicy} "$out/etc/dbus-1/system.d/inputremapper.Control.conf"
      '';
  });
in {
  config = lib.mkIf (config.settings.gui != "none" && config.settings.inputRemapper.enable) {
    services.input-remapper = {
      enable = true;
      package = inputRemapperPackage;
    };
  };
}
