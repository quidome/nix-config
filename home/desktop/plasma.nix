{ config, lib, ... }:
{
  config = lib.mkIf (config.my.gui == "plasma") {
    programs.zellij.settings.copy_command = "wl-copy";
  };
}
