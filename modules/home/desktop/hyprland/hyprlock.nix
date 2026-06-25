{lib}: {
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
        path = "screenshot";
        blur_passes = 2;
        blur_size = 6;
      }
    ];

    input-field = [
      {
        size = "220, 48";
        position = "0, -80";
        monitor = "";
        dots_center = true;
        fade_on_empty = false;
        outline_thickness = 2;
        placeholder_text = "Password...";
        shadow_passes = 1;
      }
    ];
  };
}
