{ lib, ... }:
with lib;
{
  imports = [
    ./my.nix

    ./desktop
    ./profiles
    ./services
    ./wayland.nix
  ];
}
