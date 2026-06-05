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
      bat.enable = config.programs.bat.enable;
      delta.enable = config.programs.delta.enable;
      eza.enable = config.programs.eza.enable;
      fuzzel.enable = config.programs.fuzzel.enable;
      ghostty.enable = config.programs.ghostty.enable;
      helix.enable = config.programs.helix.enable;
      hyprlock = {
        enable = config.programs.hyprlock.enable;
        useDefaultConfig = false;
      };
      mako.enable = config.services.mako.enable;
      nvim.enable = config.programs.neovim.enable;
      starship.enable = config.programs.starship.enable;
      waybar.enable = config.programs.waybar.enable;
      zed.enable = config.programs.zed-editor.enable;
      zellij.enable = config.programs.zellij.enable;
      zsh-syntax-highlighting.enable = config.programs.zsh.syntaxHighlighting.enable;
      hyprland.enable = false;

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
