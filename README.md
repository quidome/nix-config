# nix-config

In this repository I keep my flake based nixos and home-manager configurations.
Next to that, there is a configuration to build live-cds.

## Nixos

Just stand in the root of this repository and run nixos-rebuild.

```sh
sudo nixos-rebuild --flake . switch
```

## Home manager

Home manager is not used as a module and should be ran seperately.

```sh
home-manager --flake . switch
```

## Live cd

Ran from the root of this repo.

```sh
nix build .#nixosConfigurations.baseIso.config.system.build.isoImage
```

After a successful build, the iso can be found in `result/iso/`. Use cp to copy the image to for instance an usb thumb drive.

```sh
sudo cp result/iso/nixos-minimal-25.05.20250525.7c43f08-x86_64-linux.iso /dev/sdb
```

Don't forget to replace the destination drive with the proper drive.

## Remote install with nix anywhere

The live iso contains ssh public keys, has sshd running and contains nmtui to setup the network. Once the network is up, use nixos-anywhere to install the system:

```sh
nix run github:nix-community/nixos-anywhere -- --flake .#${TARGET_HOST} --generate-hardware-config nixos-generate-config hosts/${TARGET_HOST}/hardware-configuration.nix --target-host root@${TARGET_HOST_IP}
```
