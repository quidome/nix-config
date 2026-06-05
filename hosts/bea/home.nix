{
  config,
  lib,
  pkgs,
  ...
}: let
  displayTools = import ../../modules/home/desktop/hyprland/display-profile.nix {inherit lib pkgs;};
in {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "26.05";

  settings = {
    terminalFont.size = 10;
    gnome.enableAppIndicator = true;
  };

  services.kanshi = lib.mkIf (config.settings.gui == "hyprland") {
    enable = true;
    settings = [
      {
        profile = {
          name = "desktop";
          # exec = [displayTools.cleanupCmd];
          outputs = [
            {
              criteria = "DP-1";
              status = "enable";
              mode = "3440x1440@59.973";
            }
            {
              criteria = "DP-3";
              status = "disable";
            }
          ];
        };
      }
      {
        profile = {
          name = "gaming";
          # exec = [displayTools.cleanupCmd];
          outputs = [
            {
              criteria = "DP-3";
              status = "enable";
              mode = "2560x1440@144";
            }
            {
              criteria = "DP-1";
              status = "disable";
            }
          ];
        };
      }
      {
        profile = {
          name = "dual-monitors";
          # exec = [displayTools.cleanupCmd];
          outputs = [
            {
              criteria = "DP-1";
              status = "enable";
              mode = "3440x1440@59.973";
              position = "2560,0";
            }
            {
              criteria = "DP-3";
              status = "enable";
              mode = "2560x1440@144";
              position = "0,0";
            }
          ];
        };
      }
    ];
  };
}
