{...}: {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "26.05";

  settings.gnome.enableAppIndicator = false;

  programs.firefox.configPath = ".mozilla/firefox";
}
