{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.programs.ghostty.enable {
    # Only values that differ from Ghostty's defaults.
    programs.ghostty.settings = {
      font-family = "JetBrainsMono Nerd Font";
      # Follows the light/dark mode of the desktop; same flavors as Zellij.
      theme = "light:Catppuccin Latte,dark:Catppuccin Mocha";
      # Let the desktop draw the title bar.
      window-decoration = "server";
      scrollbar = "never";
      # Other hosts do not know TERM=xterm-ghostty: over SSH, send a known
      # TERM or install Ghostty's terminfo there.
      shell-integration-features = "ssh-env,ssh-terminfo";
    };
  };
}
