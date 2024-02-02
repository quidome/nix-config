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
  ];

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
        formatter.command = "nixpkgs-fmt";
      }
    ];

    language-server = {
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
