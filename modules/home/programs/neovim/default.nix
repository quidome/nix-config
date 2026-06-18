{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.programs.neovim;
  airlineTheme =
    if config.settings.theme == "light"
    then "light"
    else "base16_mocha";
in {
  config = lib.mkIf cfg.enable {
    programs.neovim = {
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withPython3 = true;
      withRuby = true;

      extraPackages = with pkgs; [
        fd
        ripgrep
      ];

      plugins = with pkgs.vimPlugins; [
        nerdtree
        tabular
        vim-airline
        vim-airline-themes
        vim-dirdiff
        vim-fugitive
        vim-gitgutter
        vim-go
        vim-nix
        vim-puppet
      ];

      extraConfig =
        ''
          let g:airline_theme = '${airlineTheme}'
        ''
        + builtins.readFile ./extraConfig.vim;
    };
  };
}
