{
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  config = {
    settings.terminalFont.size = 11;

    home.stateVersion = "25.11";

    services.shikane.enable = false;

    wayland.windowManager.hyprland.settings.monitor = [
      ",preferred,auto,auto"
      "DP-1, disable"
    ];
  };
}
