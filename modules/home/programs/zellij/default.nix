{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.zellij;
  isLight = config.settings.theme == "light";
  zellijTheme =
    if isLight
    then "catppuccin-latte"
    else "catppuccin-mocha";
  catppuccinLatte = {
    fg = [76 79 105];
    bg = [239 241 245];
    red = [210 15 57];
    green = [30 102 245];
    yellow = [223 142 29];
    blue = [30 102 245];
    magenta = [136 57 239];
    orange = [254 100 11];
    cyan = [23 146 153];
    black = [92 95 119];
    white = [204 208 218];
  };
  catppuccinMocha = {
    fg = [205 214 244];
    bg = [30 30 46];
    red = [243 139 168];
    green = [137 180 250];
    yellow = [249 226 175];
    blue = [137 180 250];
    magenta = [203 166 247];
    orange = [250 179 135];
    cyan = [137 220 235];
    black = [69 71 90];
    white = [186 194 222];
  };
in {
  config = lib.mkIf cfg.enable {
    programs.zellij = {
      settings = {
        keybinds = {
          unbind = "Ctrl b";
          shared_except = {
            _args = ["locked"];
            bind = {
              _args = ["Ctrl q"];
              "" = "Detach";
            };
          };
        };
        scrollback_editor = lib.mkIf config.programs.helix.enable (lib.getExe pkgs.helix);
        pane_frames = false;
        themes = {
          catppuccin-latte = catppuccinLatte;
          catppuccin-mocha = catppuccinMocha;
        };
        theme = zellijTheme;
        default_layout = "layout";
        show_startup_tips = false;
        copy_command = "wl-copy";
      };
    };

    xdg.configFile."zellij/layouts/layout.kdl".source = ./layout.kdl;
    home.file.".env.d/05-always-zellij.sh".source = ./always-zellij.sh;
  };
}
