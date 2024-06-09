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
        copy_command = "wl-copy";
      };
    };

    xdg.configFile."zellij/layouts/layout.kdl".source = ./layout.kdl;
    home.file.".env.d/05-always-zellij.sh".text = ''
      # some exceptions in which case zellij should not be used
      if  [ -n "$TMUX" ] ||
          [[ "$GIO_LAUNCHED_DESKTOP_FILE" == *"guake.desktop"* ]] ||
          [ "$__CFBundleIdentifier" = "io.lapce" ] ||
          [[ "$(tty)" =~ /dev/tty[0-9] ]] ||
          [[ "$TERM" == screen* ]] ||
          [[ "$TERM" == "" ]] ||
          [ "$TERM_PROGRAM" = "vscode" ] ||
          [ "$TERMINAL_EMULATOR" = "JetBrains-JediTerm" ] ||
          [ "$NO_TMUX" = "1" ] ||
          [ "$NO_ZELLIJ" = "1" ] ||
          [ "$INSIDE_EMACS" = 'vterm' ]
      then
          return 1
      fi

    
      if [[ $TERM != "screen-256color" && $TERM != "linux" && -z "$ZELLIJ" ]] ; then
        if [[ "$(zellij ls -s)" = "default-session" ]]; then
          zellij attach 'default-session'
        else
          zellij attach -c 'default-session'
        fi
      fi
    '';
  };
}
