{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.my.programs.git;
in
{
  options.my.programs.git = {
    enable = lib.mkEnableOption "Enable git";

    userEmail = lib.mkOption {
      type = types.lines;
      description = "The git config email";
      default = "";
    };

    userName = lib.mkOption {
      type = types.lines;
      description = "The git config name";
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userEmail = cfg.userEmail;
      userName = cfg.userName;
      delta.enable = true;
      extraConfig = {
        core.excludesfile = "${config.home.homeDirectory}/.gitignore_global";
        branch.autosetuprebase = "always";
        color.ui = "auto";
        pull.rebase = true;
        rebase.autoStash = true;
      };
      # Aliases
      aliases = {
        "hist" = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
    };
  };
}
