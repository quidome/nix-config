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
      package = pkgs.vscode.fhs; # Use FHS-compatible version for extensions with native binaries
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = true;

      extensions = with pkgs.vscode-extensions; [
        arrterian.nix-env-selector
        jnoortheen.nix-ide
      ];

      userSettings = {
        "git.autofetch" = true;
        "update.mode" = "none";
      };
    };
  };
}
