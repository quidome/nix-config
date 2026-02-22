{
  config,
  lib,
  ...
}: let
  cfg = config.networking.networkmanager;
in {
  config = lib.mkIf (!cfg.enable) {
    networking.useDHCP = false;

    systemd.network = {
      enable = true;

      netdevs = {};

      networks = {
        "10-enp4s0" = {
          matchConfig.Name = "enp4s0";
          networkConfig.DHCP = "yes";
          dhcpV4Config.RouteMetric = 1024;
          dhcpV4Config.UseDomains = true;
          linkConfig.RequiredForOnline = "no";
        };
        "11-enp42s0" = {
          matchConfig.Name = "enp42s0";
          networkConfig.DHCP = "yes";
          dhcpV4Config.RouteMetric = 2048;
          dhcpV4Config.UseDomains = true;
        };
        "12-enp47s0f3u3u3" = {
          matchConfig.Name = "enp47s0f3u3u3";
          networkConfig.DHCP = "yes";
          dhcpV4Config.RouteMetric = 3072;
          dhcpV4Config.UseDomains = true;
          linkConfig.RequiredForOnline = "no";
        };
      };
    };

    services.resolved.enable = true;
  };
}
