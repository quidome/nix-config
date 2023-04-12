{ lib, pkgs, ... }:
with lib;
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  imports =
    (optional (isDarwin) ./workstation-darwin.nix) ++
    (optional (!isDarwin) ./workstation-linux.nix) ++
    [
      ./workstation-common.nix
    ];
}
