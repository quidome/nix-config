{
  config,
  lib,
  ...
}: let
  cfg = config.programs.zsh;
in {
  config = lib.mkIf cfg.enable {
    home.file.".env.d/70-dev.sh".source = ./zsh/dev.sh;

    programs = {
      # enable starship
      starship.enable = true;

      fzf = {
        enable = true;
        enableZshIntegration = true;
        historyWidgetOptions = [
          "--height 40%"
          "--layout=reverse"
          "--border"
        ];
      };

      zsh = {
        shellAliases = {
          find = "noglob find";
        };

        enableCompletion = true;
        autosuggestion.enable = true;
        history = {
          size = 50000;
          save = 50000;
          ignoreDups = true;
        };

        defaultKeymap = "emacs";

        syntaxHighlighting.enable = true;

        initContent = ''
          # unfortunally a few system paths end up in front of my profile path
          # this just adds the path (again) before the other paths
          export PATH=${config.home.profileDirectory}/bin:$PATH

          # source all .sh file in .env.d
          if [ -d "$HOME"/.env.d ]; then
            for i in "$HOME"/.env.d/*.sh; do
              if [ -r $i ]; then
                . $i
              fi
            done
            unset i
          fi
        '';
      };
    };
  };
}
