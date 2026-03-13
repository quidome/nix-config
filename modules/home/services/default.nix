{lib, ...}: {
  imports = [
    ./hypridle.nix
    ./mako.nix
    ./swayidle.nix
  ];

  services.kanshi.systemdTarget = lib.mkDefault "graphical-session.target";
}
