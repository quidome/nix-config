{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.settings.profile;
in {
  config = lib.mkIf cfg.workstation {
    home.packages = with pkgs; [mpv];

    fonts.fontconfig.enable = mkDefault true;

    programs.firefox.enable = mkDefault true;
    programs.wezterm.enable = mkDefault true;
    programs.wofi.enable = mkDefault config.settings.wayland.enable;
    programs.zed-editor.enable = mkDefault true;

    settings.terminalFont.name = mkDefault "JetBrainsMono Nerd Font";

    services.syncthing.enable = mkDefault true;
  };
}
