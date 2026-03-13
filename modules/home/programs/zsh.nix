{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.zsh;
in {
  config = mkIf cfg.enable {
    home.file.".env.d/70-dev.sh".source = ./zsh/dev.sh;

    # enable starship
    programs.starship.enable = true;

    programs.zsh = {
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

        download_nixpkgs_cache_index () {
          filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr A-Z a-z)"
          (
            mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
            # -N will only download a new version if there is an update.
            wget -q -N https://github.com/nix-community/nix-index-database/releases/latest/download/$filename
            ln -f $filename files
          )
        }
      '';
    };
  };
}
