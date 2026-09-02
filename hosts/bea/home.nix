{
  config,
  lib,
  pkgs,
  ...
}: let
  dellOutput = {
    name = "Dell Inc. DELL P3424WE FB6Y6T3";
    search = [
      "m=DELL P3424WE"
      "s=FB6Y6T3"
      "v=Dell Inc."
    ];
  };
  samsungOutput = {
    name = "Samsung Electric Company LC32G5xT HK2W200965";
    search = [
      "m=LC32G5xT"
      "s=HK2W200965"
      "v=Samsung Electric Company"
    ];
  };
  enabledOutput = output: {
    search = output.search;
    enable = true;
    mode = "preferred";
    position = {
      x = 0;
      y = 0;
    };
    scale = 1.0;
    transform = "normal";
  };
  disabledOutput = output: {
    search = output.search;
    enable = false;
  };
  shikanectl = lib.getExe' pkgs.shikane "shikanectl";
in {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "26.05";

  settings.terminalFont.size = 10;

  settings.niri = {
    extraConfig = ''
      output "${dellOutput.name}" {
        focus-at-startup
      }

      output "${samsungOutput.name}" {
        off
        variable-refresh-rate on-demand=true
      }
    '';

    extraBinds = ''
      Mod+Alt+D hotkey-overlay-title="Desktop display" { spawn "${shikanectl}" "switch" "desktop"; }
      Mod+Alt+G hotkey-overlay-title="Simrig display" { spawn "${shikanectl}" "switch" "simrig"; }
    '';
  };

  services.shikane = lib.mkIf (config.settings.gui == "niri") {
    enable = true;
    settings.profile = [
      {
        name = "desktop";
        output = [
          (enabledOutput dellOutput)
          (disabledOutput samsungOutput)
        ];
      }
      {
        name = "simrig";
        output = [
          (disabledOutput dellOutput)
          (enabledOutput samsungOutput)
        ];
      }
      {
        name = "desktop-only";
        output = [(enabledOutput dellOutput)];
      }
      {
        name = "simrig-only";
        output = [(enabledOutput samsungOutput)];
      }
    ];
  };

  systemd.user.services.shikane = lib.mkIf (config.settings.gui == "niri") {
    Unit.X-Restart-Triggers = [
      "${config.xdg.configFile."shikane/config.toml".source}"
    ];
  };

  home.packages = with pkgs; [discord];

  wayland.windowManager.hyprland.settings = lib.mkIf (config.settings.gui == "hyprland") {
    device = [
      {
        name = "mosart-semi.-2.4g-wireless-mouse";
        left_handed = false;
        natural_scroll = true;
      }
      {
        name = "microsoft-microsoft®-nano-transceiver-v2.0-mouse";
        left_handed = false;
        natural_scroll = false;
      }
    ];

    config.monitor = [
      "desc:Dell Inc. DELL P3424WE FB6Y6T3, preferred, auto, 1"
      "desc:Samsung Electric Company LC32G5xT HK2W200965, disable"
    ];
  };
}
