{ config, lib, pkgs, ... }:
{
  imports = [
    ./shared.nix
    ./home-vars.nix
    ../../home
  ];

  home.stateVersion = "24.05";
  home.packages = with pkgs; [ shikane ];

  wayland.windowManager.hyprland.settings.bindl = [
    "SHIFT, code:133, exec, shikanectl switch disable-external"
  ];

  services.shikane = {
    enable = true;
    settings.profile = [
      {
        name = "home";
        output = [
          {
            search = [ "m=0x14F9" "s=" "v=Sharp Corporation" ];
            enable = true;
            position = { x = 3440; y = 240; };
            scale = 1.0;
            transform = "normal";
          }
          {
            search = [ "m=DELL P3424WE" "s=FB6Y6T3" ];
            enable = true;
            position = { x = 0; y = 0; };
            scale = 1.0;
            transform = "normal";
          }
        ];
      }
      {
        name = "default";
        output = [
          {
            match = "eDP-1";
            enable = true;
            position = { x = 0; y = 0; };
            scale = 1.0;
            transform = "normal";
          }
          {
            match = "DP-3";
            enable = true;
            position = { x = 1920; y = 0; };
            scale = 1.0;
            transform = "normal";
          }
        ];
      }
      {
        name = "standalone";
        output = [
          {
            match = "eDP-1";
            enable = true;
            position = {
              x = 0;
              y = 0;
            };
            scale = 1.0;
            transform = "normal";
          }
        ];
      }
      {
        name = "disable-external";
        output = [
          { match = "eDP-1"; enable = true; }
          { match = "DP-3"; enable = false; }
        ];
      }
    ];
  };
}
