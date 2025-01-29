{
  disko.devices = {
    disk.main = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          bios_boot = {
            priority = 1;
            size = "1M";
            type = "EF02";
          };
          boot = {
            priority = 2;
            name = "ESP";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/rootfs" = { mountpoint = "/"; };
                "/home" = { mountOptions = [ "compress=zstd" ]; mountpoint = "/home"; };
                "/nix" = { mountOptions = [ "compress=zstd" "noatime" ]; mountpoint = "/nix"; };
                "/var/log" = { mountpoint = "/var/log"; };
                "/swap" = {
                  mountpoint = "/.swapvol";
                  swap.swapfile.size = "2G";
                };
              };
              mountpoint = "/partition-root";
            };
          };
        };
      };
    };
  };
}
