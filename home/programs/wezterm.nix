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
        enable_tab_bar = false,
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
