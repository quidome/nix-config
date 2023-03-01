{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.my.programs.zsh;
in
{
  options.my.programs.zsh = {
    enable = mkEnableOption "Enable zsh";
  };

  config = mkIf cfg.enable {
    # enable starship
    my.programs.starship.enable = true;

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
        ## initExtra

        # source all .sh file in .env.d
        if [ -d "$HOME"/.env.d ]; then
          for i in "$HOME"/.env.d/*.sh; do
            if [ -r $i ]; then
              . $i
            fi
          done
          unset i
        fi

        ## initExtra end
      '';
    };
  };
}
