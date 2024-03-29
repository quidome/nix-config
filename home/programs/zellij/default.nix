{ config, lib, pkgs, ... }:
let
  zellijEnabled = config.programs.zellij.enable;
  helixEnabled = config.programs.helix.enable;
  copyCommandEnabled = config.my.gui == "kde" || config.my.gui == "gnome";
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
        copy_command = lib.mkIf copyCommandEnabled "wl-copy";
      };
    };

    xdg.configFile."zellij/layouts/layout.kdl".source = ./layout.kdl;
    home.file.".env.d/05-always-zellij.sh".text = ''
      if [[ $TERM != "screen-256color" && $TERM != "linux" && -z "$ZELLIJ" ]] ; then
        if [[ $(zellij ls 2>/dev/null |grep ^truce$) = "work" ]]; then
          zellij attach 'truce'
        else
          zellij attach -c 'truce'
        fi
      fi
    '';
  };
}
