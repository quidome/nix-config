{
  lib,
  config,
  ...
}: let
  cfg = config.programs.helix;
in {
  imports = [./languages.nix];

  config = lib.mkIf cfg.enable {
    programs.helix = {
      defaultEditor = true;
      settings = {
        theme = "molokai";
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
            mode.normal = "NORMAL";
            mode.insert = "INSERT";
            mode.select = "SELECT";
          };
        };
      };
    };
  };
}
