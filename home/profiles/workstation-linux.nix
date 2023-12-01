{ config, pkgs, lib, ... }:
with lib;
let isDarwin = pkgs.stdenv.isDarwin;
in
{
  config = mkIf (config.my.profile == "workstation" && !isDarwin) {
    home.packages = with pkgs; [
      adoptopenjdk-icedtea-web
      calibre
      digikam
      emacs
      go
      obsidian
      signal-desktop
      spotify
      vscode
    ];

    programs.firefox.enable = true;

    services.gpg-agent.enableSshSupport = true;
    services.gpg-agent.enable = true;
    services.gpg-agent.pinentryFlavor = "qt";
  };
}
