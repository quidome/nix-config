{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "plasma") {
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
