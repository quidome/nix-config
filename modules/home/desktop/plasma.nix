{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  plasmaEnabled = config.settings.gui == "plasma";
  konsoleColorscheme =
    if config.settings.theme == "light"
    then "Catppuccin-Latte"
    else "Catppuccin-Mocha";
in {
  config = mkIf plasmaEnabled {
    # Catppuccin Konsole colorschemes
    home.file.".local/share/konsole/Catppuccin-Mocha.colorscheme" = {
      enable = true;
      source = ../dotfiles/Catppuccin-Mocha.colorscheme;
    };
    home.file.".local/share/konsole/Catppuccin-Latte.colorscheme" = {
      enable = true;
      source = ../dotfiles/Catppuccin-Latte.colorscheme;
    };

    services.gpg-agent = {
      enableSshSupport = false; # Plasma uses ssh-agent + ksshaskpass + KWallet
      pinentry.package = pkgs.pinentry-qt;
    };
  };
}
