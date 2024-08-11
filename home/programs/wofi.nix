{ lib, pkgs, config, ... }:
let
  cfg = config.programs.wofi;
in
{
  config = lib.mkIf cfg.enable {
    programs.wofi.settings = {
      width = 600;
      lines = 7;
    };

    xdg.configFile."wofi/style.css".text = ''
      @define-color foreground #b1b1b1;
      @define-color background rgba (40, 40, 40, 0.85);
      @define-color border @foreground;

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
        color: #d8dee9;
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
