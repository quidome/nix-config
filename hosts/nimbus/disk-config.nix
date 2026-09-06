{...}: {
  imports = [
    (import ../../modules/system/disk-config.nix {
      device = "/dev/disk/by-id/nvme-eui.00000000000000018ce38e050049c88b";
    })
  ];
}
