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
      brew "openssl"
      brew "xz"

      # Dev
      brew "go"
      brew "libyaml"
      brew "poetry"
      brew "pyenv-virtualenv"
      brew "pyenv"

      cask "bitwarden"
      cask "blender"
      cask "gimp"
      cask "inkscape"
      cask "lapce"
      cask "logseq"
      cask "obsidian"
      cask "raycast"
      cask "signal"
    '';
  };
}
