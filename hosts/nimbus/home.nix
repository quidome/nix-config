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
            scale = 1.15;
          }
        ];
      }
      {
        profile.name = "attic-external-left";
        profile.outputs = [
          {
            criteria = "Sharp Corporation 0x14F9 Unknown";
            status = "enable";
            scale = 1.15;
            position = "3440,395";
          }
          {
            criteria = "Dell Inc. DELL P3424WE FB6Y6T3";
            status = "enable";
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "attic-internal-only";
        profile.outputs = [
          {
            criteria = "Sharp Corporation 0x14F9 Unknown";
            status = "enable";
            scale = 1.15;
          }
          {
            criteria = "Dell Inc. DELL P3424WE FB6Y6T3";
            status = "disable";
          }
        ];
      }
      {
        profile.name = "attic-external-only";
        profile.outputs = [
          {
            criteria = "Sharp Corporation 0x14F9 Unknown";
            status = "disable";
          }
          {
            criteria = "Dell Inc. DELL P3424WE FB6Y6T3";
            status = "enable";
          }
        ];
      }
    ];
  };

  wayland.windowManager.hyprland.settings.bindl = [
    "SHIFT, code:133, exec, shikanectl switch disable-external"
  ];
}
