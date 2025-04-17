{ pkgs, ... }:
{
  imports = [
    ./shared.nix
    ../../home
    ./home-vars.nix
  ];

  config = {

    home = {
      stateVersion = "23.11";
      packages = with pkgs; [
        # dev tools
        postgresql
        jetbrains.idea-community
        temurin-bin-21
        ktlint
        v4l-utils
        zed-editor
      ];
    };
  };
}
