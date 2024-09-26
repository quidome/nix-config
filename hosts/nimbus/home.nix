{ pkgs, ... }:
let
  my-python-packages = ps: with ps; [
    pip
  ];
in
{
  imports = [
    ./shared.nix
    ./home-vars.nix
    ../../home
  ];

  home = {
    stateVersion = "24.05";
    packages = with pkgs; [
      httpie
      ipcalc

      # dev tools
      jetbrains.idea-community
      poetry
      postgresql
      temurin-bin-21
      (python3.withPackages my-python-packages)
    ];
  };

  services.kanshi.settings = [
    {
      profile.name = "laptop-only";
      profile.outputs = [
        {
          criteria = "eDP-1";
          scale = 1.1;
        }
      ];
    }
  ];
}
