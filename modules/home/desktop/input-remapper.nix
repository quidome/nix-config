{
  config,
  lib,
  pkgs,
  ...
}: let
  enabled = builtins.elem config.settings.gui ["gnome" "niri"];
in {
  config = lib.mkIf enabled {
    # Per-device mouse overrides. EV_REL=2, REL_WHEEL=8,
    # REL_WHEEL_HI_RES=11, EV_KEY=1, BTN_LEFT=272, BTN_RIGHT=273.
    home.file = {
      ".config/input-remapper-2/config.json".text = builtins.toJSON {
        version = "2.2.0";
        autoload = {
          "MOSART Semi. 2.4G Wireless Mouse" = "natural-scroll";
          "Logitech USB Optical Mouse" = "natural-scroll-and-buttons";
        };
      };

      ".config/input-remapper-2/presets/MOSART Semi. 2.4G Wireless Mouse/natural-scroll.json".text = builtins.toJSON [
        {
          input_combination = [
            {
              type = 2;
              code = 8;
            }
          ];
          target_uinput = "mouse";
          output_type = 2;
          output_code = 8;
          gain = -1.0;
        }
        {
          input_combination = [
            {
              type = 2;
              code = 11;
            }
          ];
          target_uinput = "mouse";
          output_type = 2;
          output_code = 11;
          gain = -1.0;
        }
      ];

      # The package autostart runs before USB input devices are always ready.
      ".config/autostart/input-remapper-autoload.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=input-remapper-autoload
        Hidden=true
      '';

      ".config/input-remapper-2/presets/Logitech USB Optical Mouse/natural-scroll-and-buttons.json".text = builtins.toJSON [
        {
          input_combination = [
            {
              type = 1;
              code = 272;
            }
          ];
          target_uinput = "mouse";
          output_symbol = "BTN_RIGHT";
        }
        {
          input_combination = [
            {
              type = 1;
              code = 273;
            }
          ];
          target_uinput = "mouse";
          output_symbol = "BTN_LEFT";
        }
        {
          input_combination = [
            {
              type = 2;
              code = 8;
            }
          ];
          target_uinput = "mouse";
          output_type = 2;
          output_code = 8;
          gain = -1.0;
        }
        {
          input_combination = [
            {
              type = 2;
              code = 11;
            }
          ];
          target_uinput = "mouse";
          output_type = 2;
          output_code = 11;
          gain = -1.0;
        }
      ];
    };

    systemd.user.services.input-remapper-autoload = {
      Unit = {
        Description = "Load input-remapper presets after the graphical session is ready";
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
        # Do not autoload this session's mappings if the previous session was not cleaned up.
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.input-remapper}/bin/input-remapper-control --command stop-all && ${pkgs.input-remapper}/bin/input-remapper-control --command autoload'";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
