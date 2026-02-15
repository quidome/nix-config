{
  config,
  lib,
  ...
}: let
  cfg = config.programs.wezterm;
  font = config.settings.terminalFont;
in {
  programs.wezterm = lib.mkIf cfg.enable {
    extraConfig = ''
      return {
        hide_tab_bar_if_only_one_tab = true,
        font = wezterm.font('${font.name}', { weight = 'Light'}),
        font_size = ${toString font.size},
        color_scheme = "Monokai Remastered",

        -- Window
        window_padding = {
          left = 10,
          right = 10,
          top = 10,
          bottom = 10,
        },
      }
    '';
  };
}
