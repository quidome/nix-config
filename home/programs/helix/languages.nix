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
        name = "nix";
        auto-format = true;
        formatter = {
          command = "nixpkgs-fmt";
        };
      }
      {
        name = "javascript";
        auto-format = true;
      }
      {
        name = "yaml";
        config = {
          yaml.keyOrdering = false;
        };
      }
      {
        name = "json";
        auto-format = true;
        language-server.command = "vscode-json-languageserver";
        formatter = {
          args = [ "--parser" "json" ];
          command = "prettier";
        };
      }
    ];
  };
}
