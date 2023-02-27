{ nixpkgs, config, pkgs, lib, ... }:

{
  imports = [
    # ../../modules/programs/neovim.nix
  ];

  home = {
    username = "qmeijer";
    stateVersion = "22.11";
  };

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  programs.kitty = {
    enable = true;
    theme = "Earthsong";
    font.name = "Source Code Pro";
    font.size = 13;
  };

  home.packages = with pkgs;
    [
      # Some basics
      coreutils
      curl
      wget

      # Useful nix related tools
      cachix # adding/managing alternative binary caches hosted by Cachix
      comma # run software from without installing it
      niv # easy dependency management for nix projects
      rnix-lsp # nix language server

    ] ++ lib.optionals stdenv.isDarwin [
      cocoapods
      m-cli # useful macOS CLI commands
    ];

  # Misc configuration files --------------------------------------------------------------------{{{
}
