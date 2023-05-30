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

      brew "openssl"
      brew "pyenv-virtualenv"
      brew "pyenv"
      brew "xz"

      cask "bitwarden"
      cask "blender"
      cask "browserosaurus"
      cask "gimp"
      cask "inkscape"
      cask "obsidian"
      cask "raycast"
      cask "rectangle"
      cask "signal"
    '';
  };
}
