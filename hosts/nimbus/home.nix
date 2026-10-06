{
  config,
  lib,
  ...
}: {
  imports = [
    ./home-vars.nix
  ];

  # With the Dell screen connected, use only the Dell and switch off the
  # laptop screen.
  services.kanshi = lib.mkIf (config.settings.gui == "niri") {
    enable = true;
    settings = [
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Dell Inc. DELL P3424WE FB6Y6T3";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      }
    ];
  };

  home.stateVersion = "26.05";
}
