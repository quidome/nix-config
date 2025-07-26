{
  config,
  lib,
  ...
}: let
  cfg = config.programs.wezterm;
  font = config.settings.terminalFont;
in {
  programs.wezterm = lib.mkIf cfg.enable {
    colorSchemes = {
      simColors = {
        ansi = [
          "#2e3436"
          "#fc3e3e"
          "#66b31e"
          "#f6d922"
          "#5183c4"
          "#c36ccf"
          "#19a5a7"
          "#d3d7cf"
        ];
        brights = [
          "#555753"
          "#f06464"
          "#8ae234"
          "#fce94f"
          "#729fcf"
          "#c164b6"
          "#429bf1"
          "#eeeeec"
        ];
        background = "#3f3f3f";
        foreground = "#dedede";
        cursor_bg = "#949cbb";
        cursor_border = "#949cbb";
        cursor_fg = "#303446";
        selection_bg = "#737994";
        selection_fg = "#303446";
      };
    };
    extraConfig = ''
      return {
        enable_tab_bar = false,
        -- harfbuzz_features = {"calt=0", "cv01", "cv02", "cv04", "ss01", "ss03", "ss04", "cv31", "cv08", "cv30", "cv27"},
        font = wezterm.font('${font.name}', { weight = 'Light'}),
        font_size = ${toString font.size},
        color_scheme = "Molokai",

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
