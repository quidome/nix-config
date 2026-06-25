{
  config,
  lib,
  ...
}: let
  cfg = config.programs.git;
  isLight = config.settings.theme == "light";
in {
  config = lib.mkIf cfg.enable {
    programs.delta = {
      enable = true;
      options = lib.mkIf isLight {
        syntax-theme = "Catppuccin Latte";
        light = true;
      };
    };

    programs.git = {
      settings = {
        branch.autosetuprebase = "always";
        color.ui = "auto";
        core.excludesfile = "${config.home.homeDirectory}/.gitignore_global";
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        rebase.autoStash = true;
        # Aliases
        alias = {
          "hist" = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        };
      };
    };
  };
}
