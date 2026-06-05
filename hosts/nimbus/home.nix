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

  settings.gnome.enableAppIndicator = false;

  services.kanshi = lib.mkIf (config.settings.gui == "hyprland") {
    enable = true;
    settings = [
      {
        profile.name = "internal";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.15;
          }
        ];
      }
      {
        profile.name = "external-only";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-1";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "external-left";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.15;
            position = "3440,395";
          }
          {
            criteria = "DP-1";
            status = "enable";
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "internal-only";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.15;
          }
          {
            criteria = "*";
            status = "disable";
          }
        ];
      }
    ];
  };
}
