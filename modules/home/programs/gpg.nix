{
  lib,
  pkgs,
  ...
}: {
  programs.gpg.enable = true;

  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 3600;
    defaultCacheTtlSsh = 3600;
    maxCacheTtl = 14400;
    maxCacheTtlSsh = 14400;
    pinentry.package = lib.mkDefault pkgs.pinentry-qt;
  };
}
