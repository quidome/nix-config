{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.settings.roles.media.enable && config.settings.gui != "none") {
    environment.systemPackages = with pkgs; [
      kdePackages.kdenlive

      # 3D modelling and printing
      blender
      orca-slicer
    ];
  };
}
