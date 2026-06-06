{
  config,
  lib,
  ...
}:
with lib; let
  ghosttyEnabled = config.settings.terminal == "ghostty";
in {
  config = mkIf ghosttyEnabled {
    programs.ghostty = {
      enable = mkDefault true;
      settings = {
        term = "xterm-256color";
        "font-family" = mkDefault config.settings.terminalFont.name;
        "font-size" = mkDefault config.settings.terminalFont.size;
      };
    };
  };
}
