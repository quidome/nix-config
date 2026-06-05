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
        "font-family" = mkDefault config.settings.terminalFont.name;
        "font-size" = mkDefault config.settings.terminalFont.size;
      };
    };
  };
}
