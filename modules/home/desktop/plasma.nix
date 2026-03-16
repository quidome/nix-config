{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  plasmaEnabled = config.settings.gui == "plasma";
in {
  config = mkIf plasmaEnabled {
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
