{
  config,
  lib,
  ...
}: {
  systemd.services.greetd.serviceConfig = lib.mkIf config.services.greetd.enable {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
}
