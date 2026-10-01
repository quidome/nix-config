{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "niri") {
    programs.niri.enable = lib.mkDefault true;

    services.greetd = {
      enable = lib.mkDefault true;
      useTextGreeter = lib.mkDefault true;
      # Do not remember users on the login screen.
      settings.default_session.command = lib.mkDefault "${lib.getExe pkgs.tuigreet} --time --asterisks --cmd ${lib.getExe' config.programs.niri.package "niri-session"}";
    };
  };
}
