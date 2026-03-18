{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.programs.wofi;

  # Catppuccin Latte colors
  latteColors = {
    base = "rgba(239, 241, 245, 0.9)";
    text = "#4c4f69";
    surface0 = "#ccd0da";
    overlay0 = "#9ca0b0";
  };

  # Catppuccin Mocha colors
  mochaColors = {
    base = "rgba(30, 30, 46, 0.9)";
    text = "#cdd6f4";
    surface0 = "#313244";
    overlay0 = "#6c7086";
  };

  colors =
    if config.settings.theme == "light"
    then latteColors
    else mochaColors;
in {
  config = lib.mkIf cfg.enable {
    programs.wofi.settings = {
      width = 600;
      lines = 7;
    };

    xdg.configFile."wofi/style.css".text = ''
      @define-color foreground ${colors.text};
      @define-color background ${colors.base};
      @define-color border ${colors.overlay0};

      #window {
        padding: 2px;
        background-color: transparent;
        border-radius: 2px;
        font-family: 'Noto Sans', 'Inter Nerd Font','FuraCode Nerd Font Mono';
        font-size: 15px;
      }

      #input {
        border: 2px solid @border;
        background-color: @background;
        color: @foreground;
        padding: 3px 5px 3px 5px;
        border-radius: 5px;
      }

      #entry:selected {
        background-color: @foreground;
        border-radius: 5px;
      }

      #text:selected {
        color: @background;
      }

      #inner-box {
        color: @foreground;
        border-radius: 5px;
        padding: 2px;
        background-color: @background;
      }

      #outer-box {
        margin: 15px;
        background-color: transparent;
      }

      #scroll {
        margin-top: 10px;
        background-color: transparent;
        border: none;
      }

      #text {
        padding: 3px;
        color: @foreground;
        background-color: transparent;
      }

      #img {
        background-color: transparent;
        padding: 5px;
      }
    '';
  };
}
