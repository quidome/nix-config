{
  config,
  lib,
  ...
}: let
  cfg = config.networking.networkmanager;
in {
  config = lib.mkIf (!cfg.enable) {
    systemd.network = {
      enable = true;

      netdevs = {};

      networks = {
        "10-enp4s0" = {
          matchConfig.Name = "enp4s0";
          networkConfig.DHCP = "yes";
        };
        "11-enp42s0" = {
          matchConfig.Name = "enp42s0";
          networkConfig.DHCP = "no";
          linkConfig.RequiredForOnline = "no";
        };
        "12-enp47s0f3u4u3" = {
          matchConfig.Name = "enp47s0f3u4u3";
          networkConfig.DHCP = "no";
          linkConfig.RequiredForOnline = "no";
        };
      };
    };

    services.resolved.enable = true;
  };
}
