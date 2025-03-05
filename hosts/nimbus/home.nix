{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./shared.nix
    ./home-vars.nix
    ../../home
  ];

  home = {
    stateVersion = "24.05";
    packages = with pkgs; [
      # dev tools
      jetbrains.idea-community
    ];
  };

  services.kanshi.settings = mkIf (builtins.elem config.settings.gui [ "sway" "hyprland" ]) [
    {
      profile.name = "undocked";
      profile.outputs = [{ criteria = "eDP-1"; status = "enable"; scale = 1.0; }];
    }
    {
      profile.name = "home-office";
      profile.outputs = [
        { criteria = "Dell Inc. DELL P3424WE FB6Y6T3"; status = "enable"; scale = 1.0; mode = "3440x1440"; }
        { criteria = "eDP-1"; status = "disable"; }
      ];
    }
  ];
}
