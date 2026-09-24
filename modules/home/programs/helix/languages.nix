{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.programs.helix.enable {
  home.packages = with pkgs; [
    gopls
    delve
    marksman # markdown lsp
    nixd
    bash-language-server
    dockerfile-language-server
    prettier # json formatter
    typescript-language-server
    vscode-langservers-extracted
    yaml-language-server
    python3Packages.python-lsp-server

    rustfmt
    rust-analyzer

    vscode-extensions.vadimcn.vscode-lldb
  ];

  # Default config:
  # https://github.com/helix-editor/helix/blob/master/languages.toml
  programs.helix.languages = {
    language = [
      {
        name = "json";
        auto-format = true;
        language-servers = [
          "vscode-json-language-server"
        ];
      }

      {
        name = "nix";
        auto-format = true;
        formatter.command = lib.getExe pkgs.alejandra;
        language-servers = ["nixd"];
      }

      {
        name = "rust";
        auto-format = true;
        language-servers = [
          "rust-analyzer"
          # "buffer-language-server"
        ];
        # No --edition: let rustfmt pick it up from Cargo.toml.
        formatter.command = lib.getExe pkgs.rustfmt;
      }
    ];

    language-server = {
      rust-analyzer = {
        command = lib.getExe pkgs.rust-analyzer;
        config.rust-analyzer = {
          cargo = {
            buildScripts.enable = true;
            features = "all";
          };
          # checkOnSave.command = "clippy";
          # procMacro.enable = true;
        };
      };

      vscode-json-language-server = {
        command = "vscode-json-languageserver";
        args = ["--stdio"];
        config = {provideFormatter = true;};
      };

      yaml-language-server = {
        args = ["--stdio"];
        config.yaml.keyOrdering = false;
      };
    };
  };
}
