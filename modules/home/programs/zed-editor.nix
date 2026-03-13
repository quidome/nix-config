{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.zed-editor;
  font = config.settings.terminalFont;
in {
  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      extensions = [
        "nix"
        "rust"
        "toml"
      ];
      extraPackages = with pkgs; [nixd];
      userSettings = {
        auto_install_extensions = true;
        auto_update = false;

        features.copilot = false;
        telemetry.metrics = false;
        telemetry.diagnostics = false;

        # Set Claude as default agent
        agent = {
          default_model = {
            provider = "anthropic";
            model = "claude-sonnet-4.5";
          };
          button = true;
        };

        vim_mode = false;
        ui_font_size = 16;
        buffer_font_size = font.size + 3;
        buffer_font_family = font.name;

        # Editor preferences
        format_on_save = "on";
        tab_size = 2;
        soft_wrap = "editor_width";

        # File syntax highlighting
        file_types = {JSON = ["json" "jsonc" "*.code-snippets"];};

        languages = {
          Nix.language_servers = ["nixd" "!nil"];
          # Since I cannot get this to work via the LSP, formatting is arranged here.
          Nix.formatter.external = {
            command = lib.getExe pkgs.alejandra;
            arguments = ["--quiet" "--"];
          };

          # Disable auto-formatting for YAML and Go templates
          YAML.format_on_save = "off";
          "Go Template".format_on_save = "off";
        };

        lsp = {
          nix.binary.path_lookup = true;

          # Elixir/Erlang LSP settings
          elixir-ls.settings.dialyzerEnabled = true;
        };
      };
    };
  };
}
