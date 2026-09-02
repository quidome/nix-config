{
  config,
  lib,
  ...
}: let
  sessionTarget =
    if config.settings.gui == "hyprland"
    then "hyprland-session.target"
    else "graphical-session.target";
in {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  services.shikane = lib.mkIf (lib.elem config.settings.gui ["hyprland" "niri"]) {
    enable = true;
    settings.profile = [
      {
        name = "internal";
        output = [
          {
            search = "n=eDP-1";
            enable = true;
            position = {
              x = 0;
              y = 0;
            };
            scale = 1.15;
            transform = "normal";
          }
        ];
      }
      {
        name = "external-only";
        output = [
          {
            search = "n=eDP-1";
            enable = false;
          }
          {
            search = "n=DP-1";
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
    ];
  };

  systemd.user.services.shikane = lib.mkIf (lib.elem config.settings.gui ["hyprland" "niri"]) {
    Unit = {
      After = lib.mkForce [sessionTarget];
      PartOf = lib.mkForce [sessionTarget];
    };
    Install.WantedBy = lib.mkForce [sessionTarget];
  };

  home.stateVersion = "26.05";
}
