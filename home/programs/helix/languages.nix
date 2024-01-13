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
    language-server = {
      #   yaml.language-server = {
      #     command = lib.getExe pkgs.nodePackages.yaml-language-server;
      #     args = [ "--stdio" ];
      #     config = {
      #       yaml.keyOrdering = false;
      #     };
      #   };
      vscode-json-language-server = {
        command = lib.getExe nodePackages.vscode-json-languageserver;
        args = [ "--stdio" ];
        config = { provideFormatter = true; };
      };
    };

    language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = lib.getExe nixpkgs-fmt;
      }
      #  {
      #    name = "javascript";
      #   auto-format = true;
      # }
      {
        name = "json";
        auto-format = true;
        language-servers = [
          "vscode-json-language-server"
        ];
        # formatter = {
        #   args = [ "--parser" "json" ];
        #   command = "prettier";
        # };
      }
    ];
  };
}
