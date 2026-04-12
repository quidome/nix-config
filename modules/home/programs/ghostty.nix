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
    keybind = mkDefault [
      # Disable tab keybinds (using zellij for multiplexing)
      "ctrl+shift+t=unbind"
      "ctrl+shift+w=unbind"
      "ctrl+shift+tab=unbind"
      "ctrl+tab=unbind"
      "ctrl+shift+arrow_left=unbind"
      "ctrl+shift+arrow_right=unbind"
      "ctrl+page_up=unbind"
      "ctrl+page_down=unbind"
      # Disable split keybinds (using zellij for multiplexing)
      "ctrl+shift+o=unbind"
      "ctrl+shift+e=unbind"
      "ctrl+shift+enter=unbind"
      "alt+1=unbind"
      "alt+2=unbind"
      "alt+3=unbind"
      "alt+4=unbind"
      "alt+5=unbind"
      "alt+6=unbind"
      "alt+7=unbind"
      "alt+8=unbind"
      "alt+9=unbind"
      "alt+digit_1=unbind"
      "alt+digit_2=unbind"
      "alt+digit_3=unbind"
      "alt+digit_4=unbind"
      "alt+digit_5=unbind"
      "alt+digit_6=unbind"
      "alt+digit_7=unbind"
      "alt+digit_8=unbind"
      "alt+digit_9=unbind"
      # Disable split navigation keybinds (using zellij for multiplexing)
      "ctrl+alt+arrow_up=unbind"
      "ctrl+alt+arrow_down=unbind"
      "ctrl+alt+arrow_left=unbind"
      "ctrl+alt+arrow_right=unbind"
      "super+ctrl+shift+arrow_up=unbind"
      "super+ctrl+shift+arrow_down=unbind"
      "super+ctrl+shift+arrow_left=unbind"
      "super+ctrl+shift+arrow_right=unbind"
      # Prevent alt+arrow conflicts with zellij
      "alt+left=unbind"
      "alt+right=unbind"
    ];
  };
}
