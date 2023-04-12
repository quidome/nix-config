{ nixpkgs, config, pkgs, lib, ... }:
{
  imports = [
    ../../home
    ./vars.nix
  ];

  home = {
    stateVersion = "22.11";
    packages = with pkgs; [
      # Basic tools
      rcm
      pinentry_mac

      # dev tools
      go
      jless
      maven
      pandoc
      pipenv
      plantuml
      poetry
      postgresql
      shellcheck
      yq-go

      # Docker/Cloud
      gitui
      colima
      docker-client
      docker-compose
      docker-credential-helpers
      k9s
      kubectx
      stern

      # other apps
      bitwarden-cli
      discord
      gimp
      rectangle
    ];

    sessionPath = [
      "${config.home.homeDirectory}/bin"
      "${config.home.homeDirectory}/go/bin"
      "${config.home.homeDirectory}/.cargo/bin"
      "/Applications/IntelliJ IDEA.app/Contents/MacOS"
    ];

    sessionVariables = {
      DEV_PATH = "${config.home.homeDirectory}/dev";
    };
  };

  programs = {
    alacritty.enable = true;

    direnv.enable = true;
    direnv.nix-direnv.enable = true;
  };
}
