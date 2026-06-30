{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.programs.neovim;
  isLight = config.settings.theme == "light";
  airlineTheme =
    if isLight
    then "light"
    else "base16_mocha";
  colorScheme =
    if isLight
    then "catppuccin-latte"
    else "catppuccin-mocha";
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

      plugins = with pkgs.vimPlugins;
        [
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
        ]
        ++ [
          catppuccin-nvim
        ];

      extraConfig =
        ''
          let g:airline_theme = '${airlineTheme}'
          colorscheme ${colorScheme}
        ''
        + builtins.readFile ./extraConfig.vim;
    };
  };
}
