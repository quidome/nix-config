{ nixpkgs, config, pkgs, lib, ... }:

{
  imports = [
    ../../home
    ./vars.nix
  ];

  my.programs.alacritty.enable = true;
  my.programs.zsh.enable = true;

  home = {
    username = "qmeijer";
    stateVersion = "22.11";
    packages = with pkgs;
      [
        # Basic tools
        coreutils
        curl
        wget
        gopass
        bat
        dog
        fd
        fzf
        ripgrep
        rcm
        gnupg
        pinentry_mac

        # dev tools
        gitui
        go
        jq
        jless
        maven
        pandoc
        postgresql
        shellcheck

        # Docker/Cloud
        colima
        docker-client
        docker-compose
        docker-credential-helpers
        k9s
        kubectx
        stern

        # Useful nix related tools
        cachix # adding/managing alternative binary caches hosted by Cachix
        comma # run software from without installing it
        niv # easy dependency management for nix projects
        rnix-lsp # nix language server

      ] ++ lib.optionals stdenv.isDarwin [
        cocoapods
        m-cli # useful macOS CLI commands
      ];
  };

  programs = {
    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    htop.enable = true;
    htop.settings.show_program_path = true;
  };

  # Misc configuration files --------------------------------------------------------------------{{{


  # https://github.com/nix-community/home-manager/issues/1341#issuecomment-778820334
  # This piece of code copies all the installed app to /Applications so that Alfred picks them up
  home.activation = {
    copyApplications =
      let
        apps = pkgs.buildEnv {
          name = "home-manager-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        baseDir="$HOME/Applications/Home Manager Apps.localized"
        if [ -d "$baseDir" ]; then
          rm -rf "$baseDir"
        fi
        mkdir -p "$baseDir"
        for appFile in ${apps}/Applications/*; do
          target="$baseDir/$(basename "$appFile")"
          $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$appFile" "$baseDir"
          $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$target"
        done
      '';
  };
}
