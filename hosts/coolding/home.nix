{
  imports = [
    ./home-vars.nix
    ./shared.nix
  ];

  home.stateVersion = "25.11";

  settings = {
    terminal = "alacritty";
    programs.noctalia.enable = true;
  };
}
