{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.settings.roles.personal.enable {
    programs.ncspot.enable = lib.mkDefault true;
    services.syncthing.enable = lib.mkDefault true;
  };
}
