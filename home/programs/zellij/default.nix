{ config, lib, pkgs, ... }:
let
  zellijEnabled = config.programs.zellij.enable;
  helixEnabled = config.programs.helix.enable;
in
{
  config = lib.mkIf zellijEnabled {
    programs.zellij = {
      settings = {
        keybinds = {
          unbind = "Ctrl b";
          shared_except = {
            _args = [ "locked" ];
            bind = {
              _args = [ "Ctrl q" ];
              "" = "Detach";
            };
          };

        };
        scrollback_editor = lib.mkIf helixEnabled (lib.getExe pkgs.helix);
        pane_frames = false;
        default_layout = "layout";
      };
    };

    xdg.configFile."zellij/layouts/layout.kdl".source = ./layout.kdl;
    home.file.".env.d/05-always-zellij.sh".source = ./always-zellij.sh;
  };
}
