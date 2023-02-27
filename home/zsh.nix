{ config, pkgs, lib, ... }:
# with lib;

# let
#   cfg = config.my.programs.zsh;
# in
# {
#   options.my.programs.zsh = {
#     enable = mkEnableOption "Enable zsh";
#   };

#   config = mkIf cfg.enable {
# enable starship
#my.programs.starship.enable = true;
{
  programs.zsh = {
    enable = true;

    shellAliases = {
      find = "noglob find";
      nix-update = "darwin-rebuild switch --flake $HOME/projects/github.com/quidome/nix-config";
      vi = "nvim";
      vim = "nvim";
    };


    enableCompletion = true;
    enableAutosuggestions = true;
    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
    };

    defaultKeymap = "emacs";

    initExtra = ''
      # bind ctrl + arrows to move work forward and back
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      # get rid of current path on the right part of the prompt
      unset RPS1

      # source all .sh file in .env.d
      if [ -d "$HOME"/.env.d ]; then
        for i in "$HOME"/.env.d/*.sh; do
          if [ -r $i ]; then
            . $i
          fi
        done
        unset i
      fi

      # load known hosts into ssh completion
      zstyle -s ':completion:*:hosts' hosts _ssh_config
      [[ -r "$BOLCOM_HOSTS" ]] && _ssh_config+=($(cat "$BOLCOM_HOSTS"))
      zstyle ':completion:*:hosts' hosts $_ssh_config

      # hack for starship that won't build on arm atm
      eval "$(starship init zsh)"
    '';
  };
  # };
}
