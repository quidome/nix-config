{
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "25.11";

  programs.noctalia = {
    enableNetworkWidget = false;
    enableBrightnessWidget = false;
  };

  settings = {
    desktop.niri.noctalia.enable = true;
    services.swayidle.lockTimeout = 1800;
    terminalFont.size = 11;
  };

  services.kanshi = {
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

  wayland.windowManager.hyprland.settings.monitor = [
    ",preferred,auto,auto"
    "desc:Samsung Electric Company LC32G5xT HK2W200965, disable"
  ];
}
