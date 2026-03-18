{
  config,
  lib,
  ...
}:
with lib; let
  fontConfig = config.settings.terminalFont;
  themeConfig =
    if config.settings.theme == "light"
    then "light:catppuccin-latte,dark:catppuccin-latte"
    else "light:catppuccin-mocha,dark:catppuccin-mocha";
in {
  programs.ghostty.settings = lib.mkIf config.programs.ghostty.enable {
    font-size = mkDefault fontConfig.size;
    font-family = mkDefault fontConfig.name;
    window-width = mkDefault 120;
    window-height = mkDefault 40;
    copy-on-select = mkDefault "clipboard";
    shell-integration-features = mkDefault "ssh-env";
    theme = mkDefault themeConfig;
  };
}
