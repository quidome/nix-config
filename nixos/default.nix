{lib, ...}:
with lib; {
  imports = [
    ./secrets.nix
    ./settings.nix

    ./desktop
    ./profiles
    ./services
    ./wayland.nix
  ];
}
