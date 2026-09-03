{...}: {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "26.05";
}
