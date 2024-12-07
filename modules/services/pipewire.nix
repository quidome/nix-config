{ lib, config, ... }:
{
  config = lib.mkIf config.services.pipewire.enable {
    hardware.pulseaudio.enable = false;

    security.rtkit.enable = true;
    services.pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
