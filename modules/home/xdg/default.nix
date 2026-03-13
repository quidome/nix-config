{config, ...}: let
  cfg = config.xdg;
in {
  imports = [
    ./mimeApps.nix
  ];

  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    extraConfig = {
      XDG_SCREENSHOTS_DIR = "${cfg.userDirs.pictures}/Screenshots";
    };
  };
}
