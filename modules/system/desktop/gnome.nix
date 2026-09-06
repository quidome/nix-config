{
  config,
  pkgs,
  lib,
  ...
}: let
  inputRemapperUsers = builtins.filter (user: user != "root") (lib.attrNames config.home-manager.users);
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
      ${lib.concatMapStringsSep "\n" (user: ''
        <policy user="${lib.escapeXML user}">
          <allow send_destination="inputremapper.Control"/>
        </policy>
      '')
      inputRemapperUsers}
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
  config = lib.mkIf (config.settings.gui == "gnome") {
    assertions = [
      {
        assertion = builtins.length inputRemapperUsers <= 1;
        message = "GNOME input-remapper supports at most one non-root Home Manager user because its daemon is system-wide.";
      }
    ];
    environment.systemPackages =
      (with pkgs; [
        geary
        gnome-tweaks
        ghostty
        pavucontrol
      ])
      ++ lib.filter (x: x != null) [
        (pkgs.gnomeExtensions.caffeine or null)
        (pkgs.gnomeExtensions.display-configuration-switcher or null)
      ];

    services = {
      input-remapper = {
        enable = lib.mkDefault config.settings.inputRemapper.enable;
        package = inputRemapperPackage;
      };
      xserver.enable = lib.mkDefault true;
      desktopManager.gnome.enable = lib.mkDefault true;
      displayManager.gdm.enable = lib.mkDefault true;
      gnome.games.enable = lib.mkDefault false;
    };

    environment.gnome.excludePackages = lib.mkDefault (with pkgs; [
      gnome-tour
      gnome-user-docs
    ]);
  };
}
