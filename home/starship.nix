{ lib, pkgs, config, ... }:
with lib;
let
  starshipEnabled = config.programs.starship.enable;
in
{
  config.programs.starship = mkIf starshipEnabled {
    enableZshIntegration = config.programs.zsh.enable;
    settings = {
      format = "$hostname$status$env_var$shlvl$directory$git_branch$git_status[\\$](bold) ";

      directory.truncate_to_repo = false;

      status = {
        disabled = false;
        not_found_symbol = "";
        not_executable_symbol = "";
      };

      git_branch.format = "[$branch](bold purple)";

      # env_var.SSH_CONNECTION.format = "[ SSH ](bold bright-red)";

      git_status = {
        style = "yellow";
        modified = "✗";
        staged = "[ $count ](green)";
        renamed = "✗";
        deleted = "✗";
      };
      hostname = {
        format = "[$hostname]($style):";
      };
    };
  };
}
