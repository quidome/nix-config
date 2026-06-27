{
  config,
  lib,
  ...
}: {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "26.05";

  settings.terminalFont.size = 10;

  services.shikane = lib.mkIf (config.settings.gui == "hyprland") {
    enable = true;
    settings.profile = [
      {
        name = "desktop";
        output = [
          {
            match = "DP-1";
            enable = true;
            position = {
              x = 0;
              y = 0;
            };
            scale = 1.0;
            transform = "normal";
          }
          {
            match = "Samsung Electric Company LC32G5xT HK2W200965";
            enable = false;
          }
        ];
      }
      {
        name = "gaming";
        output = [
          {
            match = "DP-1";
            enable = false;
          }
          {
            match = "Samsung Electric Company LC32G5xT HK2W200965";
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
        name = "dual";
        output = [
          {
            match = "Samsung Electric Company LC32G5xT HK2W200965";
            enable = true;
            position = {
              x = 0;
              y = 0;
            };
            scale = 1.0;
            transform = "normal";
          }
          {
            match = "DP-1";
            enable = true;
            position = {
              x = 2560;
              y = 0;
            };
            scale = 1.0;
            transform = "normal";
          }
        ];
      }
    ];
  };

  systemd.user.services.shikane = lib.mkIf (config.settings.gui == "hyprland") {
    Unit = {
      After = lib.mkForce ["hyprland-session.target"];
      PartOf = lib.mkForce ["hyprland-session.target"];
    };
    Install.WantedBy = lib.mkForce ["hyprland-session.target"];
  };

  wayland.windowManager.hyprland.settings = lib.mkIf (config.settings.gui == "hyprland") {
    device = [
      {
        name = "mosart-semi.-2.4g-wireless-mouse";
        left_handed = false;
        natural_scroll = true;
      }
      {
        name = "microsoft-microsoft®-nano-transceiver-v2.0-mouse";
        left_handed = false;
        natural_scroll = false;
      }
    ];
  };
}
