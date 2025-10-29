{
  config,
  lib,
  ...
}: let
  cfg = config.programs.git;
in {
  config.programs.git = lib.mkIf cfg.enable {
    settings = {
      aliases."hist" = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      branch.autosetuprebase = "always";
      color.ui = "auto";
      core.excludesfile = "${config.home.homeDirectory}/.gitignore_global";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rebase.autoStash = true;
    };
  };
}
