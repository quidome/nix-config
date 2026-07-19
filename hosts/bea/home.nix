{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "26.05";

  settings.terminalFont.size = 10;

  home.packages = with pkgs; [discord];

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

    config.monitor = [
      "desc:Dell Inc. DELL P3424WE FB6Y6T3, preferred, auto, 1"
      "desc:Samsung Electric Company LC32G5xT HK2W200965, disable"
    ];
  };
}
