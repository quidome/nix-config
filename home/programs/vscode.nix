{ config, pkgs, lib, ... }:
let
  vscodeEnabled = config.programs.vscode.enable;
in
{
  programs.vscode = lib.mkIf vscodeEnabled {
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
}
