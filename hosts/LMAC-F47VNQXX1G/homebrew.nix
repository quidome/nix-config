{ config, lib, ... }:

let
  inherit (lib) mkIf;
  caskPresent = cask: lib.any (x: x.name == cask) config.homebrew.casks;
  brewEnabled = config.homebrew.enable;
in

{
  environment.shellInit = mkIf brewEnabled ''
    eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
  '';

  # https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
  programs.zsh.interactiveShellInit = mkIf brewEnabled ''
    FPATH="$(brew --prefix)/share/zsh/site-functions:''${FPATH}"
  '';

  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.global.brewfile = true;

  homebrew.taps = [
    "homebrew/cask"
    "homebrew/core"
  ];

  # Prefer installing application from the Mac App Store
  # commenting this out, it is in my way too often
  # homebrew.masApps = {
  #   "DaVinci Resolve" = 571213071;
  #   "Home Assistant" = 1099568401;
  #   "MQTT Explorer" = 1455214828;
  #   "Simplemind - Mind Mapping" = 439654199;
  #   "Slack for Desktop" = 803453959;
  #   "Telegram" = 747648890;
  #   "Things 3" = 904280696;
  #   "Whatsapp Desktop" = 1147396723;
  # };

  # If an app isn't available in the Mac App Store, or the version in the App Store has
  # limitiations, e.g., Transmit, install the Homebrew Cask.
  homebrew.casks = [
    "browserosaurus"
    "gimp"
    "obsidian"
    "raycast"
    "rectangle"
  ];

  # For cli packages that aren't currently available for macOS in `nixpkgs`.Packages should be
  # installed in `../home/default.nix` whenever possible.
  homebrew.brews = [
    "nvm"
    "pyenv"
    "pyenv-virtualenv"
  ];
}
