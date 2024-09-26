{ config, lib, pkgs, ... }:
let
  cfg = config.programs.zellij;
in
{
  config = lib.mkIf cfg.enable {
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
        scrollback_editor = lib.mkIf config.programs.helix.enable (lib.getExe pkgs.helix);
        pane_frames = false;
        default_layout = "layout";
      };
    };

    xdg.configFile."zellij/layouts/layout.kdl".source = ./layout.kdl;
    home.file.".env.d/05-always-zellij.sh".source = ./always-zellij.sh;
  };
}
