{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.zed-editor;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [alejandra];

    programs.zed-editor = {
      extensions = ["nix"];

      extraPackages = with pkgs; [
        nixd
      ];

      userSettings = {
        features = {
          copilot = false;
        };
        telemetry = {
          metrics = false;
        };
        vim_mode = false;
        ui_font_size = 16;
        buffer_font_size = 16;
        auto_install_extensions = true;

        assistant.enabled = false;
        auto_update = false;

        # File syntax highlighting
        file_types = {
          JSON = [
            "json"
            "jsonc"
            "*.code-snippets"
          ];
        };

        languages = {
          Nix.language_servers = ["nixd" "!nil"];
          Nix.formatter.external = {
            command = lib.getExe pkgs.alejandra;
            arguments = ["--quiet" "--"];
          };
        };

        lsp = {
          nix.binary.path_lookup = true;

          "nixd" = {
            initialization_options = {
              formatting.command = ["alejandra" "--quiet" "--"];
            };
          };

          # This is for other LSP servers, keep it separate
          settings.dialyzerEnabled = true;
        };
      };
    };
  };
}
