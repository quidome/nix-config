{...}: {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "26.05";

  settings = {
    terminalFont.size = 10;
    gnome.enableAppIndicator = true;
  };
}
