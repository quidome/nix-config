{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  cfg = config.programs.noctalia;
  isNiri = config.settings.gui == "niri";
  tomlFormat = pkgs.formats.toml {};
  package = pkgsUnstable.noctalia;

  rawConfig =
    if lib.isString cfg.settings
    then pkgs.writeText "noctalia-config.toml" cfg.settings
    else if builtins.isPath cfg.settings || lib.isStorePath cfg.settings
    then cfg.settings
    else tomlFormat.generate "noctalia-config.toml" cfg.settings;

  configFile =
    if cfg.validateConfig && cfg.package != null
    then
      pkgs.runCommand "noctalia-config.toml" {} ''
        ${lib.getExe cfg.package} config validate ${rawConfig} >/dev/null
        cp ${rawConfig} $out
      ''
    else rawConfig;
in {
  options.programs.noctalia = {
    enable = lib.mkEnableOption "Noctalia, a native Wayland desktop shell";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = package;
      description = "The Noctalia package to use.";
    };

    validateConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Validate the Noctalia configuration at build time.";
    };

    settings = lib.mkOption {
      type = with lib.types;
        oneOf [
          tomlFormat.type
          str
          path
        ];
      default = {};
      description = "Noctalia settings, represented as TOML.";
    };

    systemd = {
      enable = lib.mkEnableOption "a systemd user service for Noctalia";

      target = lib.mkOption {
        type = lib.types.str;
        default = "graphical-session.target";
        description = "The user systemd target that starts Noctalia.";
      };
    };
  };

  config = lib.mkIf isNiri {
    programs.noctalia = {
      enable = lib.mkDefault true;
      systemd.enable = lib.mkDefault true;
      settings = lib.mkDefault {
        shell = {
          font_family = config.settings.terminalFont.name;
          launch_apps_as_systemd_services = true;
          polkit_agent = false;
          clipboard_enabled = false;
          settings_show_advanced = false;
          telemetry_enabled = false;
          screenshot.directory = "/home/quidome/Pictures/Screenshots";
        };

        desktop_widgets.enabled = false;

        theme = {
          mode = config.settings.theme;
          source = "builtin";
          builtin = "Tokyo-Night";
          templates = {
            enable_builtin_templates = false;
            enable_community_templates = false;
          };
        };

        wallpaper = {
          enabled = true;
          fill_mode = "crop";
          default.path =
            if config.settings.wallpaper == null
            then ""
            else config.settings.wallpaper;
        };

        notification = {
          enable_daemon = true;
          history_retention_hours = 0;
        };

        idle = {
          pre_action_fade_seconds = 0;
          behavior_order = [
            "lock"
            "screen-off"
            "suspend"
          ];
          behavior = {
            lock = {
              enabled = true;
              timeout = 300;
              action = "lock";
            };
            "screen-off" = {
              enabled = true;
              timeout = 600;
              locked_timeout = 300;
              action = "screen_off";
            };
            suspend = {
              enabled = true;
              timeout = 1800;
              locked_timeout = 1500;
              action = "lock_and_suspend";
            };
          };
        };

        plugins = {
          source = [];
          enabled = [];
          auto_update = "none";
        };

        lockscreen = {
          enabled = true;
          lock_before_suspend = true;
          fingerprint = true;
        };

        lockscreen_widgets.enabled = false;

        bar.main = {
          margin_ends = 0;
          radius = 0;
          position = "top";
          thickness = 28;
          start = ["workspaces"];
          center = ["clock"];
          end = [
            "network"
            "volume"
            "brightness"
            "battery"
            "tray"
            "notifications"
            "control-center"
            "session"
          ];
        };
      };
    };

    home.packages = lib.optional (cfg.package != null) cfg.package;

    programs.waybar.enable = lib.mkForce false;
    services.avizo.enable = lib.mkForce false;
    services.mako.enable = lib.mkForce false;

    systemd.user.services.noctalia = lib.mkIf cfg.systemd.enable {
      Unit = {
        Description = "Noctalia Wayland desktop shell";
        Documentation = "https://docs.noctalia.dev/noctalia/";
        After = [cfg.systemd.target];
        PartOf = [cfg.systemd.target];
        ConditionEnvironment = "WAYLAND_DISPLAY";
        X-Restart-Triggers = ["${config.xdg.configFile."noctalia/config.toml".source}"];
      };

      Service = {
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = 2;
      };

      Install.WantedBy = [cfg.systemd.target];
    };

    assertions = [
      {
        assertion = !cfg.enable || !cfg.systemd.enable || cfg.package != null;
        message = "programs.noctalia.package cannot be null when its systemd service is enabled.";
      }
    ];

    xdg.configFile."noctalia/config.toml" = lib.mkIf (cfg.settings != {}) {
      source = configFile;
    };
  };
}
