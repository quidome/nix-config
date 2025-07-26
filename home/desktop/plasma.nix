{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "plasma" && ! config.programs.wezterm.enable) {
    programs.zellij.settings.copy_command = "wl-copy";
  };
}
