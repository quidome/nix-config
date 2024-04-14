# Contains the most common config
# headless, both applicable to linux and darwin
{ lib, pkgs, ... }: {
  home.packages = with pkgs;  [
    # Base
    bottom
    curl
    dogdns
    fd
    fzf
    git-crypt
    gitui
    gopass
    jless
    jq
    ripgrep
    shellcheck
    wget
    yq-go


    # Useful nix related tools
    cachix # adding/managing alternative binary caches hosted by Cachix
    comma # run software from without installing it
    niv # easy dependency management for nix projects
    nixpkgs-fmt

    # Mac specific
  ] ++ lib.optionals stdenv.isDarwin [
    cocoapods
    coreutils
    gnupg
    m-cli # useful macOS CLI commands
    watch
  ];

  programs.alacritty.enable = true;

  programs.bat.enable = true;
  programs.bat.config.theme = "DarkNeon";
  programs.bat.config.style = "header,snip";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.eza.enable = true;
  programs.eza.enableAliases = true;

  programs.git.enable = true;

  programs.helix.enable = true;

  programs.home-manager.enable = true;

  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  programs.ssh.enable = true;
  programs.ssh.extraConfig = "AddKeysToAgent yes";

  programs.zellij.enable = lib.mkDefault true;

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.initExtraBeforeCompInit = "fpath+=($HOME/.zsh/completion/)";
  programs.zsh.initExtra =
    ''
      v() {
      if [[ $# -eq 0 ]] ; then
        hx .
      else
        hx "$@"
      fi
      }
    '';
}
