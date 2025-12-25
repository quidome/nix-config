{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  isWorkstation = config.settings.gui != "none";
in {
  config = lib.mkIf isWorkstation {
    home.packages = with pkgs; [mpv];

    fonts.fontconfig.enable = mkDefault true;

    programs.firefox.enable = mkDefault true;
    programs.ghostty.enable = mkDefault true;
    programs.wofi.enable = mkDefault true;
    programs.zed-editor.enable = mkDefault true;

    settings.terminalFont.name = mkDefault "JetBrainsMono Nerd Font";

    services.syncthing.enable = mkDefault true;
  };
}
