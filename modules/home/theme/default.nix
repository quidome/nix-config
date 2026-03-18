{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.settings;
  flavor =
    if cfg.theme == "light"
    then "latte"
    else "mocha";
in {
  config = {
    catppuccin = {
      enable = true;
      inherit flavor;
      accent = cfg.catppuccinAccent;

      # Enable catppuccin for supported programs when they are enabled
      alacritty.enable = config.programs.alacritty.enable;
      bat.enable = config.programs.bat.enable;
      kitty.enable = config.programs.kitty.enable;
      helix.enable = config.programs.helix.enable;
      starship.enable = config.programs.starship.enable;
      tmux.enable = config.programs.tmux.enable;
      mako.enable = config.services.mako.enable;
      swaylock.enable = config.programs.swaylock.enable;
      hyprlock.enable = config.programs.hyprlock.enable;
      waybar.enable = config.programs.waybar.enable;
      zed.enable = config.programs.zed-editor.enable;
    };
  };
}
