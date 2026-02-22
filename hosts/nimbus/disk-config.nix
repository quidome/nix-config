let
  btrfs_mount_options = [
    "compress=lzo"
    "discard=async"
    "noatime"
    "rw"
    "space_cache=v2"
    "ssd"
  ];
in {
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.00000000000000018ce38e050049c88b";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["nofail" "umask=0077"];
              };
            };
            luks = {
              size = "100%";
              label = "luks";
              content = {
                type = "luks";
                name = "crypted";
                extraFormatArgs = [
                  "--cipher=aes-xts-plain64"
                  "--hash=sha256"
                  "--iter-time=1000"
                  "--key-size=256"
                  "--pbkdf-memory=1048576"
                  "--sector-size=4096"
                ];
                extraOpenArgs = [
                  "--allow-discards"
                  "--perf-no_read_workqueue"
                  "--perf-no_write_workqueue"
                ];
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = ["-L" "nixos" "-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = btrfs_mount_options ++ ["subvol=root"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = btrfs_mount_options ++ ["subvol=home"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = btrfs_mount_options ++ ["subvol=nix"];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = btrfs_mount_options ++ ["subvol=persist"];
                    };
                    "/log" = {
                      mountpoint = "/var/log";
                      mountOptions = btrfs_mount_options ++ ["subvol=log"];
                    };
                    "/swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "8G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
