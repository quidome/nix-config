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

  services.kanshi = lib.mkIf (config.settings.gui == "hyprland") {
    enable = true;
    settings = [
      {
        profile.name = "default";
        profile.outputs = [
          {
            criteria = "*";
            status = "enable";
          }
        ];
      }
    ];
  };

  wayland.windowManager.hyprland.settings = lib.mkIf (config.settings.gui == "hyprland") {
    monitor = [
      ", preferred, auto, auto"
      "desc:Samsung Electric Company LC32G5xT HK2W200965, disable"
    ];

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
