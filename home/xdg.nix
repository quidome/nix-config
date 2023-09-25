{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.my.xdg;
in
{
  options.my.xdg.enable = mkEnableOption "xdg";

  config = mkIf cfg.enable {
    xdg.configFile."mimeapps.list".force = true;
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "org.pwmt.zathura.desktop";
        "image/jpeg" = "feh.desktop";
        "image/png" = "feh.desktop";
        "text/html" = "browser-chooser.desktop";
        "x-scheme-handler/about" = "browser-chooser.desktop";
        "x-scheme-handler/element" = "Electron.desktop";
        "x-scheme-handler/http" = "browser-chooser.desktop";
        "x-scheme-handler/https" = "browser-chooser.desktop";
        "x-scheme-handler/msteams" = "teams.desktop";
        "x-scheme-handler/sgnl" = "signal-desktop.desktop";
        "x-scheme-handler/signalcaptcha" = "signal-desktop.desktop";
        "x-scheme-handler/unknown" = "browser-chooser.desktop";
      };
    };
  };
}
