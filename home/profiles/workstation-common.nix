{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.my.profile == "workstation") {
    my.syncthing.enable = true;

    home = {
      packages = with pkgs; [
        gitui
        go
        jless
        pandoc
        pipenv
        plantuml
        poetry
        shellcheck
        yq-go

        bitwarden-cli
        discord
        gimp
      ] ++ lib.optionals stdenv.isDarwin [
        rectangle
      ];

      sessionPath = [
        "${config.home.homeDirectory}/bin"
        "${config.home.homeDirectory}/go/bin"
        "${config.home.homeDirectory}/.cargo/bin"
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
  };
}
