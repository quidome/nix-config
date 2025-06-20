{
  config,
  pkgs,
  lib,
  ...
}: let
  authorizedKeys = config.settings.authorizedKeys;
in {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  environment.systemPackages = with pkgs; [
    fd
    git
    helix
    htop
  ];

  networking.networkmanager.enable = true; # nmtui for wi-fi
  networking.wireless.enable = lib.mkForce false;

  systemd.services.sshd.wantedBy = lib.mkForce ["multi-user.target"];

  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;
  users.users.nixos.openssh.authorizedKeys.keys = authorizedKeys;
}
