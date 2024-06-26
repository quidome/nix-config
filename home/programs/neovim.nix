{ pkgs, config, lib, ... }:
let
  neovimEnabled = config.programs.neovim.enable;
in
{
  config = lib.mkIf neovimEnabled {
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    programs.neovim = {
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraConfig = builtins.readFile ./neovim/extraConfig.vim;

      plugins = with pkgs.vimPlugins; [
        tender-vim
        vim-nix
        gruvbox
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
