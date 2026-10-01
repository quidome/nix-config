{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.settings.roles.personal.enable {
    services.syncthing.enable = lib.mkDefault true;
  };
}
