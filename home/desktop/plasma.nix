{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "plasma") {
    programs.zellij.settings.copy_command = "wl-copy";
  };
}
