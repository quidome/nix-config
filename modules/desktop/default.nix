{ lib, ...}:
{
  imports = [
    ./cosmic.nix
    ./gnome.nix
    ./pantheon.nix
    ./plasma.nix
    ./sway.nix
    ./hyprland.nix
  ];

  # Enable printing and printer discovery
  services.printing.enable = lib.mkDefault true;
  services.avahi = {
    enable = lib.mkDefault true;
    nssmdns4 = lib.mkDefault true;
    openFirewall = lib.mkDefault true;
  };
}
