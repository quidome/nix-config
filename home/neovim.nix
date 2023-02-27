{config, pkgs, ... }:
{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = builtins.readFile ./neovim/extraConfig.vim;

    plugins = with pkgs.vimPlugins; [
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
}
