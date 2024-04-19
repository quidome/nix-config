{ pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  config = lib.mkIf (isDarwin) {
    home.packages = [
    ];
  };
}
