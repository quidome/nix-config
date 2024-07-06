# Live images

This directory contains my flakes for building custom images. 
Based on this page on Nixos wiki: 
https://nixos.wiki/wiki/Creating_a_NixOS_live_CD

## Image list

| image | description |
| ----- | ----------- |
| baseIso | base iso, adds public ssh keys and a few cli tools |

## Build image

Pick an image from above and run

```sh
nix build .#nixosConfigurations.<image name>.config.system.build.isoImage
```

For building a base image, that would be:

```sh
nix build .#nixosConfigurations.baseIso.config.system.build.isoImage
```

Upon completion, the image can be found in `result/iso/` , like this:

```sh
$ ls -la live-image/result/iso 
.r--r--r-- 1.1G root  1 Jan  1970 nixos-24.05.20240531.63dacb4-x86_64-linux.iso
```

## Write image to usb device

Make sure the drive is not mounted and simply copy the image to it:

```sh
cp live-image/result/iso/nixos-xxx.iso /dev/sdX
```

Writing the disk image with `dd if=live-image/result/iso/nixos-xxx.iso of=/dev/sdX bs=4M status=progress conv=fdatasync` also works.
