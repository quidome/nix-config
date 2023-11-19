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
      brew "go"               # Go programming language
      brew "libyaml"
      brew "rtx"              # Meta language manager

      cask "bitwarden"
      cask "emacs"
      cask "gimp"
      cask "inkscape"
      cask "obsidian"
      cask "raycast"
      cask "signal"
    '';
  };
}
