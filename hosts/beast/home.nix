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

        # some tools
        android-tools
        cointop
        discord
        blender

        # office
        libreoffice-qt
        hunspell
        hunspellDicts.nl_NL
        hunspellDicts.en_US-large
        hunspellDicts.en_GB-large
      ];
    };

    wayland.windowManager.sway.config.output = {
      DP-1 = {
        disable = "";
        bg = "#000000 solid_color";
      };
    };

    services.kanshi.enable = false;
  };
}
