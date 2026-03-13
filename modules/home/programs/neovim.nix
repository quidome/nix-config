{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.programs.neovim;
in {
  config = lib.mkIf cfg.enable {
    programs.neovim = {
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraConfig = builtins.readFile ./neovim/extraConfig.vim;

      plugins = with pkgs.vimPlugins; [
        tender-vim
        vim-nix
        gruvbox
        tokyonight-nvim
        nerdtree
        rainbow
        vim-gitgutter
        vim-airline
        vim-airline-themes
        vim-go
        vim-puppet
        tabular
        nerdtree
        vim-fugitive
        vim-dirdiff
      ];
    };
  };
}
