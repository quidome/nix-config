{ config, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      bitwarden-cli
      go
      rcm
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
}
