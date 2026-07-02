{
  config,
  lib,
}: let
  isLightTheme = config.settings.theme == "light";
  colors =
    if isLightTheme
    then {
      base = "rgba(239, 241, 245, 0.92)";
      text = "rgba(76, 79, 105, 1.0)";
      surface = "rgba(204, 208, 218, 0.72)";
      overlay = "rgba(156, 160, 176, 1.0)";
      accent = "rgba(30, 102, 245, 1.0)";
      red = "rgba(210, 15, 57, 1.0)";
      lockBackground = "rgba(220, 224, 232, 1.0)";
    }
    else {
      base = "rgba(30, 30, 46, 0.86)";
      text = "rgba(205, 214, 244, 1.0)";
      surface = "rgba(49, 50, 68, 0.72)";
      overlay = "rgba(108, 112, 134, 1.0)";
      accent = "rgba(137, 180, 250, 1.0)";
      red = "rgba(243, 139, 168, 1.0)";
      lockBackground = "rgba(49, 50, 68, 1.0)";
    };
in {
  enable = lib.mkDefault true;

  settings = {
    general = {
      disable_loading_bar = true;
      grace = 5;
      hide_cursor = true;
      no_fade_in = true;
    };

    background = [
      {
        color = colors.lockBackground;
      }
    ];

    label = [
      {
        text = ''cmd[update:1000] date +"%H:%M"'';
        color = colors.text;
        font_size = 72;
        font_family = "JetBrainsMono Nerd Font";
        position = "0, 130";
        halign = "center";
        valign = "center";
        shadow_passes = 2;
      }
      {
        text = ''cmd[update:60000] date +"%A, %d %B"'';
        color = colors.overlay;
        font_size = 18;
        font_family = "Noto Sans";
        position = "0, 70";
        halign = "center";
        valign = "center";
        shadow_passes = 1;
      }
      {
        text = "Press Enter, then scan fingerprint";
        color = colors.overlay;
        font_size = 14;
        font_family = "Noto Sans";
        position = "0, -125";
        halign = "center";
        valign = "center";
      }
    ];

    input-field = [
      {
        size = "280, 52";
        position = "0, -60";
        monitor = "";
        dots_center = true;
        fade_on_empty = false;
        outline_thickness = 2;
        rounding = 12;
        placeholder_text = "Enter → scan, or type password";
        font_family = "JetBrainsMono Nerd Font";
        font_color = colors.text;
        inner_color = colors.base;
        outer_color = colors.overlay;
        check_color = colors.accent;
        fail_color = colors.red;
        capslock_color = colors.red;
        numlock_color = colors.accent;
        shadow_passes = 1;
      }
    ];
  };
}
