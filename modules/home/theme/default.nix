{
  config,
  lib,
  pkgs,
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
      bat.enable = config.programs.bat.enable;
      helix.enable = config.programs.helix.enable;
      starship.enable = config.programs.starship.enable;
      zed.enable = config.programs.zed-editor.enable;

      # Kvantum for Qt theming (useful for Plasma)
      kvantum.enable = cfg.preferQt;
    };

    # Configure Qt to use Kvantum when preferQt is enabled
    qt = mkIf cfg.preferQt {
      enable = true;
      style.name = "kvantum";
      platformTheme.name = "kvantum";
    };
  };
}
