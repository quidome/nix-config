{ lib, pkgs, config, ... }:
{
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.kernelPackages = lib.mkOverride 0 pkgs.linuxPackages_latest;

  environment.systemPackages = with pkgs; [
    keyutils
  ];

  networking.hostName = lib.mkForce "nixos-live-bcachefs";

  isoImage.isoName = lib.mkForce "${config.isoImage.isoBaseName}-${config.system.nixos.label}-bcachefs-${pkgs.stdenv.hostPlatform.system}.iso";
}
