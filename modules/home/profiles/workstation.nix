{
  config,
  lib,
  ...
}: let
  isWorkstation = config.settings.gui != "none";
in {
  config = lib.mkIf isWorkstation {
    fonts.fontconfig.enable = lib.mkDefault true;

    programs = {
      emacs.enable = lib.mkDefault true;
      zed-editor.enable = lib.mkDefault true;
    };

    services.syncthing.enable = lib.mkDefault true;
  };
}
