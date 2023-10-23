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
      logseq
      obsidian
      signal-desktop
      spotify
    ];

    programs.firefox.enable = true;
    programs.vscode.enable = true;

    services.gpg-agent.enableSshSupport = true;
    services.gpg-agent.enable = true;
    services.gpg-agent.pinentryFlavor = "qt";
  };
}
