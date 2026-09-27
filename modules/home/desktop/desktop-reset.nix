{
  config,
  lib,
  pkgs,
  ...
}: let
  desktopReset = pkgs.writeShellApplication {
    name = "desktop-reset";
    runtimeInputs = with pkgs; [coreutils dconf findutils gnugrep procps];
    text = builtins.readFile ./desktop-reset.sh;
  };
in {
  config = lib.mkIf (config.settings.gui != "none") {
    home.packages = [desktopReset];
  };
}
