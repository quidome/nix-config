{
  config,
  lib,
  ...
}:
with lib; let
  isWorkstation = config.settings.gui != "none";

  # Terminals that have home-manager modules (vs system-provided like konsole)
  hmTerminals = ["alacritty" "kitty" "wezterm" "ghostty"];
  terminalHasHmModule = builtins.elem config.settings.terminal hmTerminals;
in {
  config = lib.mkIf isWorkstation {
    fonts.fontconfig.enable = mkDefault true;

    programs.firefox.enable = mkDefault true;
    programs.wofi.enable = mkDefault true;
    programs.zed-editor.enable = mkDefault true;
    programs.${config.settings.terminal}.enable = mkIf terminalHasHmModule (mkDefault true);

    settings.terminalFont.name = mkDefault "JetBrainsMono Nerd Font";

    services.syncthing.enable = mkDefault true;
  };
}
