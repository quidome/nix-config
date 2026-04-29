{
  config,
  lib,
  ...
}: let
  isPlasma = config.settings.gui == "plasma";
in {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "25.11";

  settings = {
    terminalFont.size = 10;
  };

  settings.programs.noctalia = lib.mkIf (!isPlasma) {
    enableNetworkWidget = false;
    enableBrightnessWidget = false;
  };

  settings.services.swayidle.lockTimeout = lib.mkIf (!isPlasma) 1800;

  services.kanshi = lib.mkIf (config.settings.gui != "plasma") {
    enable = true;
    settings = [
      {
        profile.name = "desktop";
        profile.outputs = [
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
      }
      {
        profile.name = "gaming";
        profile.outputs = [
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
      }
      {
        profile.name = "dual-monitors";
        profile.outputs = [
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
      }
    ];
  };

  dconf.settings."org/gnome/desktop/peripherals/mice/045e:0800" = {
    natural-scroll = false;
  };

  dconf.settings."org/gnome/desktop/peripherals/mice/046d:c05a" = {
    left-handed = true;
  };

  wayland.windowManager.hyprland.settings.monitor = lib.mkIf (config.settings.gui == "hyprland") [
    ",preferred,auto,auto"
    "desc:Samsung Electric Company LC32G5xT HK2W200965, disable"
  ];
}
