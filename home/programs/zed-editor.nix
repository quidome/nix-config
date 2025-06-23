{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.zed-editor;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [nixd];

    programs.zed-editor = {
      extensions = ["nix" "rust" "toml"];

      extraPackages = with pkgs; [nixd];

      userSettings = {
        assistant.enabled = false;
        auto_install_extensions = true;
        auto_update = false;
        features.copilot = false;
        telemetry.metrics = false;

        vim_mode = false;
        ui_font_size = 16;
        buffer_font_size = 16;

        # File syntax highlighting
        file_types = {JSON = ["json" "jsonc" "*.code-snippets"];};

        languages = {
          Nix.language_servers = ["nixd" "!nil"];
          # Since I cannot get this to work via the LSP, formatting is arranged here.
          Nix.formatter.external = {
            command = lib.getExe pkgs.alejandra;
            arguments = ["--quiet" "--"];
          };
        };

        lsp = {
          nix.binary.path_lookup = true;

          # This is for other LSP servers, keep it separate
          settings.dialyzerEnabled = true;
        };
      };
    };
  };
}
