{
  config,
  lib,
  ...
}:
with lib; let
  isWorkstation = config.settings.gui != "none";
in {
  config = lib.mkIf isWorkstation {
    fonts.fontconfig.enable = mkDefault true;

    programs = {
      emacs.enable = mkDefault true;
      zed-editor.enable = mkDefault true;
    };

    services.syncthing.enable = mkDefault true;
  };
}
