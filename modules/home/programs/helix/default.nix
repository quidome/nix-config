{
  lib,
  config,
  ...
}: let
  cfg = config.programs.helix;
  isLight = config.settings.theme == "light";
  helixTheme =
    if isLight
    then "catppuccin_latte"
    else "catppuccin_mocha";
in {
  imports = [./languages.nix];

  config = lib.mkIf cfg.enable {
    programs.helix = {
      defaultEditor = true;
      settings = {
        theme = helixTheme;
        editor = {
          file-picker.hidden = false;
          line-number = "relative";
          cursorline = true;
          scrolloff = 6;
          lsp = {
            display-messages = true;
            display-signature-help-docs = false;
            display-inlay-hints = true;
          };
          cursor-shape = {
            insert = "bar";
            select = "underline";
          };
          bufferline = "always";
          soft-wrap.enable = true;
          statusline = {
            left = ["mode" "spacer" "spinner" "spacer" "version-control"];
            center = ["file-name" "file-modification-indicator" "spacer" "diagnostics"];
            right = ["position" "total-line-numbers"];
            separator = "|";
            mode = {
              normal = "NORMAL";
              insert = "INSERT";
              select = "SELECT";
            };
          };
        };
      };
    };
  };
}
