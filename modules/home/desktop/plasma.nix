{
  config,
  lib,
  ...
}: let
  isPlasma = config.settings.gui == "plasma";
  isLightTheme = config.settings.theme == "light";
  lookAndFeel =
    if isLightTheme
    then "org.kde.breeze.desktop"
    else "org.kde.breezedark.desktop";
in {
  config = lib.mkIf isPlasma {
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.plasma = {
      enable = true;

      workspace = {
        inherit lookAndFeel;
        clickItemTo = "select";
      };

      fonts = {
        general = {
          family = "Noto Sans";
          pointSize = 10;
        };
        fixedWidth = {
          family = "JetBrainsMono Nerd Font";
          pointSize = 10;
        };
      };

      input.keyboard = {
        repeatDelay = 200;
        repeatRate = 35;
      };

      panels = [
        {
          location = "bottom";
          height = 40;
          floating = true;
          widgets = [
            "org.kde.plasma.kickoff"
            {
              iconTasks.launchers = [
                "applications:firefox.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:com.mitchellh.ghostty.desktop"
              ];
            }
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.systemtray"
            "org.kde.plasma.digitalclock"
          ];
        }
      ];

      hotkeys.commands.launch-ghostty = {
        name = "Launch Ghostty";
        key = "Meta+Return";
        command = "ghostty";
      };

      configFile.kwinrc = {
        # Follow pointer focus behavior intentionally.
        Windows.FocusPolicy = "FocusFollowsMouse";
        # No hot corners.
        Effect-overview.BorderActivate = 9;
        ElectricBorders.TopLeft = "None";
      };
    };
  };
}
