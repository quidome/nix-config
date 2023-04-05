{ lib, config, ... }:
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
      tap "GoogleContainerTools/kpt https://github.com/GoogleContainerTools/kpt.git"

      brew "nvm"
      brew "pyenv-virtualenv"
      brew "pyenv"
      brew "kpt"
      
      cask  "obsidian"
      cask "browserosaurus"
      cask "gimp"
      cask "raycast"
      cask "rectangle"
    '';
  };
}
