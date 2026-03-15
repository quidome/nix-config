{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  plasmaEnabled = config.settings.gui == "plasma";
  terminal = config.settings.terminal;
in {
  config = mkIf plasmaEnabled {
    # Enable the configured terminal emulator
    programs.${terminal}.enable = true;

    # Set as Plasma's default terminal (for Dolphin "Open Terminal Here", etc.)
    # and add Meta+Return shortcut to launch it
    home.activation.setPlasmaTerminal = hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
        --file ''${XDG_CONFIG_HOME:-$HOME/.config}/kdeglobals \
        --group General \
        --key TerminalApplication \
        ${terminal}

      ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
        --file ''${XDG_CONFIG_HOME:-$HOME/.config}/kglobalshortcutsrc \
        --group org.kde.${terminal}.desktop \
        --key _launch \
        "Meta+Return,none,${terminal}"
    '';

    home.file.".local/share/konsole/Molokai.colorscheme" = {
      enable = true;
      source = ../dotfiles/Molokai.colorscheme;
    };
    home.file.".local/share/konsole/Monokai Remastered.colorscheme" = {
      enable = true;
      source = ../dotfiles/Monokai_Remastered.colorscheme;
    };
  };
}
