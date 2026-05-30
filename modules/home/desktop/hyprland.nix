{
  config,
  lib,
  pkgs,
  ...
}: let
  hyprInput = import ./hyprland/input.nix;
  hyprBind = import ./hyprland/bind.nix {inherit lib;};
  hyprSettingsCore = import ./hyprland/settings-core.nix;
  hyprRules = import ./hyprland/rules.nix {inherit lib;};
in {
  config = lib.mkIf (config.settings.gui == "hyprland") {
    home.packages = [pkgs.wofi pkgs.foot];

    wayland.windowManager.hyprland = {
      enable = lib.mkDefault true;
      settings =
        hyprSettingsCore
        // hyprRules
        // {
          config.input = hyprInput;
          bind = hyprBind;
        };
    };
  };
}
