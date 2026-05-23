{...}: {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "25.11";

  settings.gnome.enableAppIndicator = false;
}
