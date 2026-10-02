{
  config,
  lib,
  pkgs,
  ...
}: let
  # Map a list of MIME types to one default app.
  defaultFor = app: types: lib.genAttrs types (_: app);
in {
  # Plasma brings its own apps; these replace them in niri.
  config = lib.mkIf (config.settings.gui == "niri") {
    home.packages = with pkgs; [
      file-roller
      loupe
      nautilus
      papers
    ];

    # Replaces the unmanaged mimeapps.list from the Plasma time.
    xdg.mimeApps = {
      enable = true;
      defaultApplications =
        defaultFor "firefox.desktop" [
          "application/x-extension-htm"
          "application/x-extension-html"
          "application/x-extension-shtml"
          "application/x-extension-xht"
          "application/x-extension-xhtml"
          "application/xhtml+xml"
          "text/html"
          "x-scheme-handler/chrome"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ]
        # Thunderbird made these entries itself; their .desktop files are in
        # ~/.local/share/applications.
        // defaultFor "userapp-Thunderbird-VFCBU3.desktop" [
          "message/rfc822"
          "x-scheme-handler/mailto"
          "x-scheme-handler/mid"
        ]
        // defaultFor "userapp-Thunderbird-PPVIU3.desktop" [
          "application/x-extension-ics"
          "text/calendar"
          "x-scheme-handler/webcal"
          "x-scheme-handler/webcals"
        ]
        // defaultFor "userapp-Thunderbird-IYWHU3.desktop" ["x-scheme-handler/net.thunderbird"]
        // defaultFor "claude-code-url-handler.desktop" ["x-scheme-handler/claude-cli"]
        // defaultFor "gimp.desktop" ["image/vnd.adobe.photoshop"]
        // defaultFor "org.gnome.Nautilus.desktop" ["inode/directory"]
        // defaultFor "org.gnome.Papers.desktop" ["application/pdf"]
        // defaultFor "org.gnome.Loupe.desktop" [
          "image/avif"
          "image/bmp"
          "image/gif"
          "image/heic"
          "image/jpeg"
          "image/png"
          "image/svg+xml"
          "image/tiff"
          "image/webp"
        ]
        // defaultFor "org.gnome.FileRoller.desktop" [
          "application/gzip"
          "application/vnd.rar"
          "application/x-7z-compressed"
          "application/x-bzip2-compressed-tar"
          "application/x-compressed-tar"
          "application/x-tar"
          "application/x-xz-compressed-tar"
          "application/x-zstd-compressed-tar"
          "application/zip"
          "application/zstd"
        ];
    };
  };
}
