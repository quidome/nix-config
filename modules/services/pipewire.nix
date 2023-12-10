{ lib, pkgs, config, ... }:
with lib;
let
  pipewireEnabled = config.services.pipewire.enable;
in
{
  config = mkIf pipewireEnabled {
    # Remove sound.enable or turn it off if you had it set previously, it seems to cause conflicts with pipewire
    sound.enable = true;
    hardware.pulseaudio.enable = false;

    security.rtkit.enable = true;
    services.pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
