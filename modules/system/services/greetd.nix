{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.services.greetd.enable {
    # Keep boot and kernel messages from drawing over the greeter.
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}
