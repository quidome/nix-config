{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.vscode;
in {
  programs.vscode = lib.mkIf cfg.enable {
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
