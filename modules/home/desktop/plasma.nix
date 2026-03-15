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
    home.activation.setPlasmaTerminal = hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
        --file ''${XDG_CONFIG_HOME:-$HOME/.config}/kdeglobals \
        --group General \
        --key TerminalApplication \
        ${terminal}
    '';

    home.file.".local/share/konsole/Molokai.colorscheme" = {
      enable = true;
      source = ../dotfiles/Molokai.colorscheme;
    };
    home.file.".local/share/konsole/Monokai Remastered.colorscheme" = {
      enable = true;
      source = ../dotfiles/Monokai_Remastered.colorscheme;
    };

    services.gpg-agent = {
      enableSshSupport = false; # Plasma uses ssh-agent + ksshaskpass + KWallet
      pinentry.package = pkgs.pinentry-qt;
    };
  };
}
