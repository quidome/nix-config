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

  settings = {
    terminalFont.size = 10;
    gnome.enableAppIndicator = true;
  };

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

  programs.firefox.configPath = ".mozilla/firefox";
}
