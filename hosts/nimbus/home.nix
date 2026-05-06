{
  config,
  lib,
  ...
}: {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "25.11";
}
