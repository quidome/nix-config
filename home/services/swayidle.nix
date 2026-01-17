{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.settings.services.swayidle;
  noctalia = config.programs.noctalia;
in {
  options.settings.services.swayidle = {
    enable = mkEnableOption "swayidle for idle screen locking";
    idleTimeout = mkOption {
      type = types.int;
      default = 300;
      description = "Idle timeout in seconds before locking screen";
    };
    suspendTimeout = mkOption {
      type = types.int;
      default = config.settings.services.swayidle.idleTimeout + 120;
      description = "Idle timeout in seconds before suspending system";
    };
  };

  config = mkIf cfg.enable {
    services.swayidle = {
      enable = true;
      package = pkgs.swayidle;
      timeouts = [
        {
          timeout = cfg.idleTimeout;
          command =
            if noctalia.enable
            then "${pkgs.unstable.noctalia-shell}/bin/noctalia-shell ipc call lockScreen lock"
            else "${pkgs.swaylock}/bin/swaylock -f";
        }
        {
          timeout = cfg.suspendTimeout;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
      events = [
        {
          event = "before-sleep";
          command =
            if noctalia.enable
            then "${pkgs.unstable.noctalia-shell}/bin/noctalia-shell ipc call lockScreen lock"
            else "${pkgs.swaylock}/bin/swaylock -f";
        }
      ];
    };
  };
}
