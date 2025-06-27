{...}: let
in {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home = {
    stateVersion = "25.05";
  };
}
