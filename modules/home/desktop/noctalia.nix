{
  config,
  lib,
  pkgs,
  ...
}: let
  isNiri = config.settings.gui == "niri";
  package = pkgs.noctalia;

  rawConfig = (pkgs.formats.toml {}).generate "noctalia-config.toml" {
    shell = {
      font_family = "JetBrains Mono Nerd Font";
      launch_apps_as_systemd_services = true;
      # The polkit-gnome agent from niri.nix handles authentication prompts.
      polkit_agent = false;
      clipboard_enabled = false;
      settings_show_advanced = false;
      telemetry_enabled = false;
      screenshot.directory = "${config.home.homeDirectory}/Pictures/Screenshots";
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

  configFile = pkgs.runCommand "noctalia-config.toml" {} ''
    ${lib.getExe package} config validate ${rawConfig} >/dev/null
    cp ${rawConfig} $out
  '';
in {
  config = lib.mkIf isNiri {
    home.packages = [package];

    xdg.configFile."noctalia/config.toml".source = configFile;

    systemd.user.services.noctalia = {
      Unit = {
        Description = "Noctalia Wayland desktop shell";
        Documentation = "https://docs.noctalia.dev/noctalia/";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        ConditionEnvironment = "WAYLAND_DISPLAY";
        X-Restart-Triggers = ["${configFile}"];
      };

      Service = {
        ExecStart = lib.getExe package;
        Restart = "on-failure";
        RestartSec = 2;
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
