{ lib, ... }:
{
    imports = [
      ./mako.nix
      ./syncthing.nix
    ];

    services.kanshi.systemdTarget = lib.mkDefault "graphical-session.target";
}
