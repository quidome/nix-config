{
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "25.11";

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "laptop-only";
        profile.outputs = [
          {
            criteria = "Sharp Corporation 0x14F9 Unknown";
            status = "enable";
            mode = "1920x1200@59.950";
            scale = 1.15;
          }
        ];
      }
    ];
  };

  wayland.windowManager.hyprland.settings.bindl = [
    "SHIFT, code:133, exec, shikanectl switch disable-external"
  ];
}
