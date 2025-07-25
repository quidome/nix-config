{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.settings.profile;
in {
  config = lib.mkIf cfg.workstation {
    home = {
      packages = with pkgs; [
        mpv
      ];
    };

    fonts.fontconfig.enable = true;

    programs.firefox.enable = true;
    programs.wofi.enable = lib.mkDefault config.settings.wayland.enable;
    programs.zed-editor.enable = true;

    services.syncthing.enable = true;
  };
}
