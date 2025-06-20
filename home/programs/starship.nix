{
  lib,
  config,
  ...
}: let
  cfg = config.programs.starship;
in {
  config.programs.starship = lib.mkIf cfg.enable {
    settings = {
      format = "$hostname$directory$nix_shell$git_branch$git_commit$git_status$fill$golang$java$kotlin$nodejs$php$python$ruby$rust$kubernetes$line_break$status$character";
      fill.symbol = " ";

      directory.format = "[$path[$read_only]($read_only_style)]($style) ";
      directory.repo_root_format = "[$before_root_path]($style)[$repo_root]($repo_root_style)[$path[$read_only]($read_only_style)]($style) ";
      git_branch.format = "[$symbol$branch]($style) ";
      git_commit.format = "[$hash]($style) ";
      git_status.format = "([$all_status$ahead_behind]($style)) ";
      golang.format = "[$symbol($version)]($style) ";
      hostname.format = "[$hostname]($style):";
      java.format = "[$symbol($version)]($style) ";
      kotlin.format = "[$symbol($version)]($style) ";
      kubernetes.format = "[$context/$namespace]($style) ";
      nodejs.format = "[$symbol($version)]($style) ";
      php.format = "[$symbol($version)]($style) ";
      python.format = "[\${symbol}\${pyenv_prefix}(\${version})(\($virtualenv\))]($style) ";
      ruby.format = "[$symbol($version)]($style) ";
      rust.format = "[$symbol($version)]($style) ";

      directory = {
        style = "bold blue";
        repo_root_style = "bold fg:220";
      };

      git_status = {
        style = "green";
        ahead = "[↑$count](blue)";
        behind = "[↓$count](red)";
        diverged = "[↑$\\{ahead_count\\}](blue)[↓$\\{behind_count\\}](red)";
        conflicted = "✗";
        up_to_date = "✔";
        untracked = "[…](red)";
        stashed = "📦";
        modified = "[+$count](red)";
        staged = "[¤$count](green)";
        deleted = "[✗$count](red)";
      };

      kubernetes.disabled = false;

      status = {
        disabled = false;
        not_found_symbol = "";
        not_executable_symbol = "";
      };
    };
  };
}
