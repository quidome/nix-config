{...}: {
  imports = [
    (import ../../modules/system/disk-config.nix {
      device = "/dev/disk/by-id/ata-CT500MX500SSD1_2011E292A245";
    })
  ];
}
