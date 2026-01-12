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
      "desc:Samsung Electric Company LC32G5xT HK2W200965, disable"
    ];
  };
}
