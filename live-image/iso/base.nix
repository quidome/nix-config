{ pkgs, lib, ... }:
let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBaWfnH8Kf151utxsPmNvamuMW49QpLMbC5g6RxX1L6H"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtaimX+cXczZ9XwDjLRnxlVOTDjZf46PYBbwMw1fYIO"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKKNAKrwchOKKqlFJjwCJu+0Uv0X+YvWExjQ+HghNA0"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINNEJX/s8T4wQRbKkPOtJAVQHZ84SwPIR7otTLecwZ2j"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJp9yviNwbGqJAPBEz3vlQWW1ogm9ph6evCu3ppxJPPW"
  ];
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    fd
    git
    helix
    htop
  ];

  networking.networkmanager.enable = true; # nmtui for wi-fi
  networking.wireless.enable = lib.mkForce false;

  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;
}
