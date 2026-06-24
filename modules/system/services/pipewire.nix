{
  lib,
  config,
  ...
}:
with lib; {
  config = lib.mkIf config.services.pipewire.enable {
    services.pulseaudio.enable = mkDefault false;

    security.rtkit.enable = mkDefault true;
    services.pipewire = {
      alsa.enable = mkDefault true;
      alsa.support32Bit = mkDefault true;
      pulse.enable = mkDefault true;
    };
  };
}
