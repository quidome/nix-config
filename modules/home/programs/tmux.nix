{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.programs.tmux.enable {
    home.file.".env.d/05-always-tmux.sh".source = ./tmux/always-tmux.sh;
  };
}
