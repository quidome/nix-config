{
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        device = "/dev/disk/by-id/ata-CT500MX500SSD1_2011E292A245";
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
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          compression = "lz4";
          mountpoint = "none";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
          xattr = "sa";
        };
        options.ashift = "12";
        options.autotrim = "on";

        datasets = {
          "local" = {
            type = "zfs_fs";
            options.mountpoint = "none";
            options."com.sun:auto-snapshot" = "false";
            options.compression = "lz4";
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };

          "safe" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              "com.sun:auto-snapshot" = "true";
              compression = "zstd-3";
            };
          };
          "safe/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
          };
          "safe/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
          };

          "swap" = {
            type = "zfs_volume";
            size = "8G";
            options = {
              compression = "lz4";
              sync = "disabled";
              primarycache = "metadata";
              secondarycache = "none";
            };
          };
        };
      };
    };
  };
  swapDevices = [{device = "/dev/zvol/zroot/swap";}];
}
