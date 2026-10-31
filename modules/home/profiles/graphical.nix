{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui != "none") {
    fonts.fontconfig.enable = lib.mkDefault true;

    home.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.ghostty.enable = lib.mkDefault true;
  };
}
