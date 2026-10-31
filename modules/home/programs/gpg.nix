{
  lib,
  pkgs,
  ...
}: {
  programs.gpg.enable = true;

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
