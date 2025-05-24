{ pkgs, ... }:
let
  shikaneOutputDefaults = { enable = true; scale = 1.0; transform = "normal"; };
  shikaneDefaultOutput = ({ position = { x = 0; y = 0; }; } // shikaneOutputDefaults);
in
{
  imports = [
    ./shared.nix
    ./home-vars.nix
    ../../home
  ];

  home.stateVersion = "25.05";

  wayland.windowManager.hyprland.settings.bindl = [
    "SHIFT, code:133, exec, shikanectl switch disable-external"
  ];

  services.shikane = {
    settings.profile = [
      {
        name = "home";
        output = [
          { search = [ "m=0x14F9" "s=" "v=Sharp Corporation" ]; enable = false; }
          ({ search = [ "m=DELL P3424WE" "s=FB6Y6T3" ]; } // shikaneDefaultOutput)
        ];
      }
      {
        name = "default";
        output = [
          ({ match = "eDP-1"; } // shikaneDefaultOutput)
          ({ search = "n/^DP-[1-9]"; position = { x = 1920; y = 0; }; } // shikaneOutputDefaults)
        ];
      }
      {
        name = "standalone";
        output = [ ({ match = "eDP-1"; } // shikaneDefaultOutput) ];
      }
      {
        name = "disable-internal";
        output = [
          { match = "eDP-1"; enable = false; }
          { search = "n/^DP-[1-9]"; enable = true; }
        ];
      }
      {
        name = "disable-external";
        output = [
          ({ match = "eDP-1"; } // shikaneDefaultOutput)
          { search = "n/^DP-[1-9]"; enable = false; }
        ];
      }
    ];
  };
}
