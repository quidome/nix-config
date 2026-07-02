{
  config,
  lib,
  ...
}: {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  services.shikane = lib.mkIf (config.settings.gui == "hyprland") {
    enable = true;
    settings.profile = [
      {
        name = "internal";
        output = [
          {
            match = "eDP-1";
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
            match = "eDP-1";
            enable = false;
          }
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

  home.stateVersion = "26.05";
}
