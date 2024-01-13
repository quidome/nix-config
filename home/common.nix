# Contains the most common config
# headless, both applicable to linux and darwin
{ pkgs, ... }: {
  home.packages = with pkgs;  [
    # Base
    bottom
    curl
    dog
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
    rnix-lsp # nix language server

    # Mac specific
  ] ++ lib.optionals stdenv.isDarwin [
    cocoapods
    coreutils
    gnupg
    m-cli # useful macOS CLI commands
    watch
  ];


  programs.bat.enable = true;
  programs.bat.config.theme = "DarkNeon";
  programs.bat.config.style = "header,snip";

  programs.eza.enable = true;
  programs.eza.enableAliases = true;

  programs.git.enable = true;

  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  programs.ssh.enable = true;
  programs.ssh.extraConfig = "AddKeysToAgent yes";

  programs.tmux.enable = true;

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.initExtraBeforeCompInit = "fpath+=($HOME/.zsh/completion/)";
}
