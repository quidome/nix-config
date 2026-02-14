{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  config = mkIf (config.settings.gui != "none") {
    programs.vscode = {
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          arrterian.nix-env-selector
          jnoortheen.nix-ide
        ];

        enableExtensionUpdateCheck = true;
        enableUpdateCheck = false;
        userSettings = {
          "git.autofetch" = true;
          "update.mode" = "none";
        };
      };
    };
  };
}
