{
  config,
  lib,
  ...
}: let
  # Map a list of MIME types to one default app.
  defaultFor = app: types: lib.genAttrs types (_: app);
in {
  config = lib.mkIf (config.settings.gui == "niri") {
    # Replaces the unmanaged mimeapps.list from the Plasma time.
    xdg.mimeApps = {
      enable = true;
      defaultApplications =
        defaultFor "zen.desktop" [
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
