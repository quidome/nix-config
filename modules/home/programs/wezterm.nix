{
  config,
  lib,
  ...
}: let
  font = config.settings.terminalFont;
  colorScheme =
    if config.settings.theme == "light"
    then "Catppuccin Latte"
    else "Catppuccin Mocha";
in {
  config = lib.mkIf (config.settings.terminal == "wezterm") {
    programs.wezterm = {
      enable = lib.mkDefault true;
      extraConfig = ''
        return {
          hide_tab_bar_if_only_one_tab = true,
          font = wezterm.font('${font.name}', { weight = 'Light' }),
          font_size = ${toString font.size},
          color_scheme = "${colorScheme}",
          audible_bell = "Disabled",
          window_padding = {
            left = 8,
            right = 8,
            top = 8,
            bottom = 8,
          },
        }
      '';
    };
  };
}
