{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.settings.roles.gaming.enable && config.settings.gui != "none") {
    environment.systemPackages = with pkgs; [
      openttd
      zeroad
    ];
  };
}
