{ lib, ... }:
{
  imports = [
    ./mako.nix
  ];

  services.kanshi.systemdTarget = lib.mkDefault "graphical-session.target";
}
