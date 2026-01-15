{
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "25.11";

  services.kanshi = {
    enable = true;
    settings = [
      # Matches profiles are activated in other of their definition in the configuration file
      # For this machine the order is:
      # - Internal only, nothing connected
      # - External screen only on attic
      # - External screen on the left (manual trigger)
      # - Internal only, disable all other screens
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

  wayland.windowManager.hyprland.settings.bindl = [
    "SHIFT, code:133, exec, shikanectl switch disable-external"
  ];
}
