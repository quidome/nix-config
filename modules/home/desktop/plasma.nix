{
  config,
  lib,
  ...
}:
with lib; let
  isPlasma = config.settings.gui == "plasma";
in {
  config = mkIf isPlasma {
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
    };

    settings.terminal = mkDefault "konsole";
  };
}
