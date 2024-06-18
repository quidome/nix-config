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
      brew "openssl"
      brew "xz"

      # DevOps
      brew "go"
      brew "jenv"
      brew "libyaml"
      brew "pyenv"
      brew "pyenv-virtualenv"
      cask "google-cloud-sdk"
      cask "zulu@21"

      # Apps
      cask "bitwarden"
      cask "browserosaurus"
      cask "emacs"
      cask "logseq"
      cask "obsidian"
      cask "raycast"
      cask "signal"
    '';
  };
}
