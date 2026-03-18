{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.programs.neovim;
in {
  config = lib.mkIf cfg.enable {
    catppuccin.nvim.enable = true;

    programs.neovim = {
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraConfig = builtins.readFile ./neovim/extraConfig.vim;

      plugins = with pkgs.vimPlugins; [
        vim-nix
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
