{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.noctalia;
in {
  options.programs.noctalia = {
    enable = mkEnableOption "noctalia";
    enableBrightnessWidget = mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable brightness widget";
    };
    enableNetworkWidget = mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable network widget";
    };
  };

  config = mkIf cfg.enable {
    home.file = {
      ".config/noctalia/colors.json" = {
        source = config.lib.file.mkOutOfStoreSymlink ./colors.json;
      };
      ".config/noctalia/settings-generated.json" = {
        text = let
          networkWidget = optionalString cfg.enableNetworkWidget ''{ "displayMode": "onhover", "id": "Network" },'';
          brightnessWidget = optionalString cfg.enableBrightnessWidget ''{ "displayMode": "onhover", "id": "Brightness" },'';
        in ''
          {
              "appLauncher": {
                  "autoPasteClipboard": false,
                  "clipboardWrapText": true,
                  "customLaunchPrefix": "",
                  "customLaunchPrefixEnabled": false,
                  "enableClipPreview": true,
                  "enableClipboardHistory": false,
                  "iconMode": "tabler",
                  "ignoreMouseInput": false,
                  "pinnedApps": [
                  ],
                  "position": "center",
                  "screenshotAnnotationTool": "",
                  "showCategories": false,
                  "showIconBackground": true,
                  "sortByMostUsed": true,
                  "terminalCommand": "${config.settings.terminal}",
                  "useApp2Unit": false,
                  "viewMode": "list"
              },
              "audio": {
                  "cavaFrameRate": 60,
                  "mprisBlacklist": [
                  ],
                  "preferredPlayer": "vlc",
                  "visualizerType": "linear",
                  "volumeOverdrive": false,
                  "volumeStep": 5
              },
              "bar": {
                  "backgroundOpacity": 1,
                  "capsuleOpacity": 1,
                  "density": "default",
                  "exclusive": true,
                  "floating": false,
                  "marginHorizontal": 5,
                  "marginVertical": 5,
                  "monitors": [
                  ],
                  "outerCorners": true,
                  "position": "top",
                  "showCapsule": true,
                  "showOutline": false,
                  "useSeparateOpacity": false,
                  "widgets": {
                      "center": [
                          {
                              "characterCount": 2,
                              "colorizeIcons": false,
                              "enableScrollWheel": true,
                              "followFocusedScreen": false,
                              "groupedBorderOpacity": 1,
                              "hideUnoccupied": false,
                              "iconScale": 0.8,
                              "id": "Workspace",
                              "labelMode": "name",
                              "showApplications": false,
                              "showLabelsOnlyWhenOccupied": true,
                              "unfocusedIconsOpacity": 1
                          }
                      ],
                      "left": [
                          {
                              "compactMode": true,
                              "diskPath": "/",
                              "id": "SystemMonitor",
                              "showCpuTemp": true,
                              "showCpuUsage": true,
                              "showDiskUsage": false,
                              "showGpuTemp": false,
                              "showLoadAverage": false,
                              "showMemoryAsPercent": false,
                              "showMemoryUsage": true,
                              "showNetworkStats": false,
                              "useMonospaceFont": true,
                              "usePrimaryColor": false
                          },
                          {
                              "colorizeIcons": false,
                              "hideMode": "hidden",
                              "id": "ActiveWindow",
                              "maxWidth": 145,
                              "scrollingMode": "hover",
                              "showIcon": true,
                              "useFixedWidth": false
                          },
                          {
                              "compactMode": false,
                              "compactShowAlbumArt": true,
                              "compactShowVisualizer": false,
                              "hideMode": "hidden",
                              "hideWhenIdle": false,
                              "id": "MediaMini",
                              "maxWidth": 145,
                              "panelShowAlbumArt": true,
                              "panelShowVisualizer": true,
                              "scrollingMode": "hover",
                              "showAlbumArt": false,
                              "showArtistFirst": true,
                              "showProgressRing": true,
                              "showVisualizer": false,
                              "useFixedWidth": false,
                              "visualizerType": "linear"
                          }
                      ],
                      "right": [
                          {
                              "blacklist": [
                              ],
                              "colorizeIcons": false,
                              "drawerEnabled": true,
                              "hidePassive": false,
                              "id": "Tray",
                              "pinned": [
                              ]
                          },
                          {
                              "hideWhenZero": false,
                              "id": "NotificationHistory",
                              "showUnreadBadge": true
                          },
                          {
                              "displayMode": "onhover",
                              "hideIfNotDetected": true,
                              "id": "Battery",
                              "showNoctaliaPerformance": false,
                              "showPowerProfiles": false,
                              "warningThreshold": 30
                          },
                          {
                              "displayMode": "onhover",
                              "id": "Bluetooth"
                          },
                          {
                              "displayMode": "onhover",
                              "id": "Volume",
                              "middleClickCommand": "pwvucontrol || pavucontrol"
                          },
                          ${networkWidget}
                          ${brightnessWidget}
                          {
                              "customFont": "",
                              "formatHorizontal": "HH:mm ddd, MMM dd",
                              "formatVertical": "HH mm - dd MM",
                              "id": "Clock",
                              "tooltipFormat": "HH:mm ddd, MMM dd",
                              "useCustomFont": false,
                              "usePrimaryColor": true
                          },
                          {
                              "colorizeDistroLogo": false,
                              "colorizeSystemIcon": "none",
                              "customIconPath": "",
                              "enableColorization": false,
                              "icon": "noctalia",
                              "id": "ControlCenter",
                              "useDistroLogo": false
                          }
                      ]
                  }
              },
              "brightness": {
                  "brightnessStep": 5,
                  "enableDdcSupport": false,
                  "enforceMinimum": true
              },
              "calendar": {
                  "cards": [
                      {
                          "enabled": true,
                          "id": "calendar-header-card"
                      },
                      {
                          "enabled": true,
                          "id": "calendar-month-card"
                      },
                      {
                          "enabled": true,
                          "id": "weather-card"
                      }
                  ]
              },
              "colorSchemes": {
                  "darkMode": true,
                  "manualSunrise": "06:30",
                  "manualSunset": "18:30",
                  "matugenSchemeType": "scheme-fruit-salad",
                  "predefinedScheme": "Tokyo Night",
                  "schedulingMode": "off",
                  "useWallpaperColors": false
              },
              "controlCenter": {
                  "cards": [
                      {
                          "enabled": true,
                          "id": "profile-card"
                      },
                      {
                          "enabled": true,
                          "id": "shortcuts-card"
                      },
                      {
                          "enabled": true,
                          "id": "audio-card"
                      },
                      {
                          "enabled": false,
                          "id": "weather-card"
                      },
                      {
                          "enabled": true,
                          "id": "media-sysmon-card"
                      },
                      {
                          "enabled": false,
                          "id": "brightness-card"
                      }
                  ],
                  "diskPath": "/",
                  "position": "close_to_bar_button",
                  "shortcuts": {
                      "left": [
                          {
                              "id": "Network"
                          },
                          {
                              "id": "Bluetooth"
                          },
                          {
                              "id": "WallpaperSelector"
                          }
                      ],
                      "right": [
                          {
                              "id": "Notifications"
                          },
                          {
                              "id": "PowerProfile"
                          },
                          {
                              "id": "KeepAwake"
                          },
                          {
                              "id": "NightLight"
                          }
                      ]
                  }
              },
              "desktopWidgets": {
                  "enabled": false,
                  "gridSnap": false,
                  "monitorWidgets": [
                  ]
              },
              "dock": {
                  "animationSpeed": 1,
                  "backgroundOpacity": 1,
                  "colorizeIcons": false,
                  "deadOpacity": 0.6,
                  "displayMode": "always_visible",
                  "enabled": false,
                  "floatingRatio": 1,
                  "inactiveIndicators": false,
                  "monitors": [
                  ],
                  "onlySameOutput": true,
                  "pinnedApps": [
                  ],
                  "pinnedStatic": false,
                  "position": "bottom",
                  "size": 1
              },
              "general": {
                  "allowPanelsOnScreenWithoutBar": true,
                  "animationDisabled": true,
                  "animationSpeed": 1,
                  "avatarImage": "",
                  "boxRadiusRatio": 1,
                  "compactLockScreen": false,
                  "dimmerOpacity": 0.2,
                  "enableShadows": true,
                  "forceBlackScreenCorners": false,
                  "iRadiusRatio": 1,
                  "language": "",
                  "lockOnSuspend": true,
                  "radiusRatio": 1,
                  "scaleRatio": 1,
                  "screenRadiusRatio": 1,
                  "shadowDirection": "bottom_right",
                  "shadowOffsetX": 2,
                  "shadowOffsetY": 3,
                  "showChangelogOnStartup": true,
                  "showHibernateOnLockScreen": false,
                  "showScreenCorners": false,
                  "showSessionButtonsOnLockScreen": true
              },
              "hooks": {
                  "darkModeChange": "",
                  "enabled": false,
                  "performanceModeDisabled": "",
                  "performanceModeEnabled": "",
                  "screenLock": "",
                  "screenUnlock": "",
                  "wallpaperChange": ""
              },
              "location": {
                  "analogClockInCalendar": false,
                  "firstDayOfWeek": -1,
                  "hideWeatherCityName": false,
                  "hideWeatherTimezone": false,
                  "name": "Woerden",
                  "showCalendarEvents": true,
                  "showCalendarWeather": true,
                  "showWeekNumberInCalendar": true,
                  "use12hourFormat": false,
                  "useFahrenheit": false,
                  "weatherEnabled": true,
                  "weatherShowEffects": false
              },
              "network": {
                  "bluetoothDetailsViewMode": "grid",
                  "bluetoothHideUnnamedDevices": false,
                  "bluetoothRssiPollIntervalMs": 10000,
                  "bluetoothRssiPollingEnabled": false,
                  "wifiDetailsViewMode": "grid",
                  "wifiEnabled": true
              },
              "nightLight": {
                  "autoSchedule": true,
                  "dayTemp": "6500",
                  "enabled": false,
                  "forced": false,
                  "manualSunrise": "06:30",
                  "manualSunset": "18:30",
                  "nightTemp": "4000"
              },
              "notifications": {
                  "backgroundOpacity": 1,
                  "criticalUrgencyDuration": 15,
                  "enableKeyboardLayoutToast": true,
                  "enabled": true,
                  "location": "top_right",
                  "lowUrgencyDuration": 3,
                  "monitors": [
                  ],
                  "normalUrgencyDuration": 8,
                  "overlayLayer": true,
                  "respectExpireTimeout": false,
                  "saveToHistory": {
                      "critical": true,
                      "low": true,
                      "normal": true
                  },
                  "sounds": {
                      "criticalSoundFile": "",
                      "enabled": false,
                      "excludedApps": "discord,firefox,chrome,chromium,edge",
                      "lowSoundFile": "",
                      "normalSoundFile": "",
                      "separateSounds": false,
                      "volume": 0.5
                  }
              },
              "osd": {
                  "autoHideMs": 2000,
                  "backgroundOpacity": 1,
                  "enabled": true,
                  "enabledTypes": [
                      0,
                      1,
                      2,
                      4
                  ],
                  "location": "top_right",
                  "monitors": [
                  ],
                  "overlayLayer": true
              },
              "sessionMenu": {
                  "countdownDuration": 10000,
                  "enableCountdown": true,
                  "largeButtonsLayout": "grid",
                  "largeButtonsStyle": false,
                  "position": "center",
                  "powerOptions": [
                      {
                          "action": "lock",
                          "command": "",
                          "countdownEnabled": true,
                          "enabled": true
                      },
                      {
                          "action": "suspend",
                          "command": "",
                          "countdownEnabled": true,
                          "enabled": true
                      },
                      {
                          "action": "hibernate",
                          "command": "",
                          "countdownEnabled": false,
                          "enabled": false
                      },
                      {
                          "action": "reboot",
                          "command": "",
                          "countdownEnabled": true,
                          "enabled": true
                      },
                      {
                          "action": "logout",
                          "command": "",
                          "countdownEnabled": true,
                          "enabled": true
                      },
                      {
                          "action": "shutdown",
                          "command": "",
                          "countdownEnabled": true,
                          "enabled": true
                      }
                  ],
                  "showHeader": true,
                  "showNumberLabels": true
              },
              "settingsVersion": 39,
              "systemMonitor": {
                  "cpuCriticalThreshold": 90,
                  "cpuPollingInterval": 250,
                  "cpuWarningThreshold": 80,
                  "criticalColor": "",
                  "diskCriticalThreshold": 90,
                  "diskPollingInterval": 3000,
                  "diskWarningThreshold": 80,
                  "enableDgpuMonitoring": false,
                  "externalMonitor": "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor",
                  "gpuCriticalThreshold": 90,
                  "gpuPollingInterval": 3000,
                  "gpuWarningThreshold": 80,
                  "loadAvgPollingInterval": 3000,
                  "memCriticalThreshold": 90,
                  "memPollingInterval": 3000,
                  "memWarningThreshold": 80,
                  "networkPollingInterval": 3000,
                  "tempCriticalThreshold": 90,
                  "tempPollingInterval": 3000,
                  "tempWarningThreshold": 80,
                  "useCustomColors": false,
                  "warningColor": ""
              },
              "templates": {
                  "alacritty": false,
                  "cava": false,
                  "code": false,
                  "discord": false,
                  "emacs": false,
                  "enableUserTemplates": false,
                  "foot": false,
                  "fuzzel": false,
                  "ghostty": false,
                  "gtk": false,
                  "helix": false,
                  "hyprland": false,
                  "kcolorscheme": false,
                  "kitty": false,
                  "mango": false,
                  "niri": false,
                  "pywalfox": false,
                  "qt": false,
                  "spicetify": false,
                  "telegram": false,
                  "vicinae": false,
                  "walker": false,
                  "wezterm": true,
                  "yazi": false,
                  "zed": true,
                  "zenBrowser": false
              },
              "ui": {
                  "bluetoothDetailsViewMode": "grid",
                  "bluetoothHideUnnamedDevices": false,
                  "boxBorderEnabled": false,
                  "fontDefault": "JetBrainsMono Nerd Font Propo",
                  "fontDefaultScale": 1,
                  "fontFixed": "DejaVu Sans Mono",
                  "fontFixedScale": 1,
                  "networkPanelView": "wifi",
                  "panelBackgroundOpacity": 0.93,
                  "panelsAttachedToBar": true,
                  "settingsPanelMode": "attached",
                  "tooltipsEnabled": true,
                  "wifiDetailsViewMode": "grid"
              },
              "wallpaper": {
                  "directory": "/home/quidome/Pictures/Wallpapers",
                  "enableMultiMonitorDirectories": false,
                  "enabled": true,
                  "fillColor": "#000000",
                  "fillMode": "crop",
                  "hideWallpaperFilenames": false,
                  "monitorDirectories": [
                  ],
                  "overviewEnabled": false,
                  "panelPosition": "follow_bar",
                  "randomEnabled": false,
                  "randomIntervalSec": 300,
                  "recursiveSearch": true,
                  "setWallpaperOnAllMonitors": true,
                  "solidColor": "#1a1a2e",
                  "transitionDuration": 1500,
                  "transitionEdgeSmoothness": 0.05,
                  "transitionType": "random",
                  "useSolidColor": false,
                  "useWallhaven": false,
                  "wallhavenApiKey": "",
                  "wallhavenCategories": "111",
                  "wallhavenOrder": "desc",
                  "wallhavenPurity": "100",
                  "wallhavenQuery": "",
                  "wallhavenRatios": "",
                  "wallhavenResolutionHeight": "",
                  "wallhavenResolutionMode": "atleast",
                  "wallhavenResolutionWidth": "",
                  "wallhavenSorting": "relevance",
                  "wallpaperChangeMode": "random"
              }
          }
        '';
      };
    };
  };
}
