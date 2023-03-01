{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.my.programs.tmux;
in
{
  options.my.programs.tmux = {
    enable = mkEnableOption "Enable to tmux terminal multiplexer";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      historyLimit = 30000;
      baseIndex = 1;
      clock24 = true;
      terminal = "screen-256color";
      extraConfig = ''
        #set -g prefix C-b
        unbind C-t
        set -sg escape-time 0
        bind I set-window-option synchronize-panes
        bind i set-window-option synchronize-panes off
        set -g renumber-windows on
        set -g set-titles on
        bind - split-window -c "#{pane_current_path}"
        bind | split-window -h -c "#{pane_current_path}"
        unbind '"'
        unbind %
        bind r source-file ~/.tmux.conf\; display "Tmux config reloaded"
        set -g set-titles on
        set -g status-justify "left"
        set -g status "on"
        set -g status-left-length "100"
        set -g status-bg "colour237"
        set -g status-right-length "100"
        setw -g window-status-separator ""
        set -g status-left "#[fg=colour237,bg=colour247,bold] #S #[fg=colour247,bg=colour237,nobold,nounderscore,noitalics]"
        set -g status-right "#[fg=colour235,bg=colour237,nobold,nounderscore,noitalics]#[fg=colour247,bg=colour236] %Y-%m-%d  %H:%M #[fg=colour247,bg=colour236,nobold,nounderscore,noitalics]#[fg=colour237,bg=colour247] #h "
        setw -g window-status-format "#[fg=colour240,bg=colour237] #I #[fg=colour240,bg=colour237] #W "
        setw -g window-status-current-format "#[fg=colour237,bg=colour236,nobold,nounderscore,noitalics]#[fg=colour247,bg=colour236] #I #[fg=colour247,Bg:=colour236] #W #[fg=colour236,bg=colour237,nobold,nounderscore,noitalics]"
      '';
    };

  };
}
