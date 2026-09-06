{...}: {
  imports = [
    (import ../../modules/system/disk-config.nix {
      device = "/dev/disk/by-id/ata-RTNTE256PCA8EADL_sd0l82501r1sz71306zb";
    })
  ];
}
