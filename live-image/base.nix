{ pkgs, ... }:
let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBaWfnH8Kf151utxsPmNvamuMW49QpLMbC5g6RxX1L6H"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtaimX+cXczZ9XwDjLRnxlVOTDjZf46PYBbwMw1fYIO"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKKNAKrwchOKKqlFJjwCJu+0Uv0X+YvWExjQ+HghNA0"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINNEJX/s8T4wQRbKkPOtJAVQHZ84SwPIR7otTLecwZ2j"
  ];
in
{
  environment.systemPackages = with pkgs; [
    fd
    git
    helix
    htop
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;
}
