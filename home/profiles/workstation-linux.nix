{ config, pkgs, lib, ... }:
with lib;
let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinuxWorkstation = (!isDarwin && config.my.gui != "none");
in
{
  config = mkIf isLinuxWorkstation {
    home.packages = with pkgs; [
      adoptopenjdk-icedtea-web
      bitwarden
      calibre
      digikam
      emacs29
      go
      logseq
      obsidian
      signal-desktop
      spotify
      vscode
      wl-clipboard
    ];

    programs.firefox.enable = true;

    services.gpg-agent.enableSshSupport = true;
    services.gpg-agent.enable = true;
  };
}
