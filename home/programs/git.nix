{ config, lib, pkgs, ... }:
with lib;
let
  gitEnabled = config.programs.git.enable;
in
{
  config.programs.git = mkIf gitEnabled {
    delta.enable = true;
    extraConfig = {
      branch.autosetuprebase = "always";
      color.ui = "auto";
      core.excludesfile = "${config.home.homeDirectory}/.gitignore_global";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rebase.autoStash = true;
    };
    # Aliases
    aliases = {
      "hist" = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };
  };
}
