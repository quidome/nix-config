{
  config,
  lib,
  ...
}:
with lib; let
  fontConfig = config.settings.terminalFont;
in {
  programs.ghostty.settings = lib.mkIf config.programs.ghostty.enable {
    font-size = mkDefault fontConfig.size;
    font-family = mkDefault fontConfig.name;
    window-width = mkDefault 120;
    window-height = mkDefault 40;
    copy-on-select = mkDefault "clipboard";
    shell-integration-features = mkDefault "ssh-terminfo";
    theme = mkDefault "light:TokyoNight Day,dark:TokyoNight";
  };
}
