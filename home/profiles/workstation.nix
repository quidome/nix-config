{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.settings.profile;
in {
  config = lib.mkIf cfg.workstation {
    home.packages = with pkgs; [mpv];

    fonts.fontconfig.enable = true;

    programs.firefox.enable = true;
    programs.wezterm.enable = true;
    programs.wofi.enable = lib.mkDefault config.settings.wayland.enable;
    programs.zed-editor.enable = true;

    settings.terminalFont.name = "JetBrainsMono Nerd Font";
    settings.terminalFont.size = 12;

    services.syncthing.enable = true;
  };
}
