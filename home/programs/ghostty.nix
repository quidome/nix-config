{
  config,
  lib,
  ...
}: {
  programs.ghostty.settings = lib.mkIf config.programs.ghostty.enable {
    font-size = config.settings.terminalFont.size;
    window-width = 120;
    window-height = 40;
    copy-on-select = "clipboard";
  };
}
