{ pkgs, lib, config, ... }:
with pkgs;
lib.mkIf config.programs.helix.enable {

  home.packages = [
    gopls
    delve
    marksman # markdown lsp
    nil # nix lsp
    nixpkgs-fmt # nix formatter
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.prettier # json formatter
    nodePackages.typescript-language-server
    nodePackages.vscode-json-languageserver
    nodePackages.yaml-language-server
    python311Packages.python-lsp-server

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
        formatter.command = lib.getExe nixpkgs-fmt;
        language-servers = [
          "nil"
          "buffer-language-server"
        ];
      }


      {
        name = "rust";
        auto-format = true;
        language-servers = [
          "rust-analyzer"
          # "buffer-language-server"
        ];
        formatter = {
          command = lib.getExe rustfmt;
          args = [ "--edition" "2021" ];
        };
      }
    ];

    language-server = {

      rust-analyzer = {
        command = lib.getExe rust-analyzer;
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
        args = [ "--stdio" ];
        config = { provideFormatter = true; };
      };

      yaml-language-server = {
        args = [ "--stdio" ];
        config.yaml.keyOrdering = false;
      };
    };
  };
}
