{
  config,
  lib,
  pkgs,
  ...
}: let
  cosmicEnabled = config.settings.gui == "cosmic";
in {
  config = lib.mkIf cosmicEnabled {
    services.gpg-agent.pinentry.package = pkgs.pinentry-gnome3;
  };
}
