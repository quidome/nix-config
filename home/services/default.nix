{lib, ...}: {
  imports = [
    ./hypridle.nix
    ./mako.nix
  ];

  services.kanshi.systemdTarget = lib.mkDefault "graphical-session.target";
}
