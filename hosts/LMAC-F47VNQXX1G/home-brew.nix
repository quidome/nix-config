{ lib, config, pkgs, ... }:
with lib;
let
  zshEnabled = config.programs.zsh.enable;
in
{
  programs.zsh.initExtra = mkIf zshEnabled ''
    # Homebrew settings
    eval "$(/opt/homebrew/bin/brew shellenv)"
    FPATH="$(brew --prefix)/share/zsh/site-functions:''${FPATH}"
  '';

  home.sessionVariables = {
    HOMEBREW_BUNDLE_FILE = "${config.home.homeDirectory}/.config/brewfile";
  };

  home.file.brewfile = {
    target = ".config/brewfile";
    text = ''
      tap "homebrew/cask"
      tap "homebrew/core"

      brew "nvm"
      brew "pyenv-virtualenv"
      brew "pyenv"
      
      cask "obsidian"
      cask "browserosaurus"
      cask "gimp"
      cask "raycast"
    '';
  };
}
