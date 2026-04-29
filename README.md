# nix-config

In this repository I keep my flake based nixos and home-manager configurations.
Next to that, there is a configuration to build live-cds.

## NixOS

Home-manager runs as a NixOS module, so a single rebuild applies both system and user configuration.

```sh
sudo nixos-rebuild --flake . switch
```

Or using the justfile shorthand:

```sh
just switch
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

## Desktop environments

One desktop is supported via `settings.gui`: `plasma`.

The table below maps core desktop functionality to how this environment provides it.

| Requirement | Plasma |
|---|---|
| **Status bar** | built-in |
| **App launcher** | Kickoff |
| **Notifications** | built-in |
| **Screen lock** | built-in |
| **Idle / sleep** | built-in |
| **Volume / OSD** | built-in |
| **Brightness / OSD** | built-in |
| **Wallpaper** | built-in |
| **Network management** | built-in |
| **Bluetooth management** | built-in |
| **Display layout** | built-in |
| **System tray** | built-in |
| **Polkit agent** | built-in |
| **Screenshot** | Spectacle |
| **Clipboard** | built-in |
| **XDG portals** | built-in |
| **Color scheme** | KDE theming |
| **Secret storage** | KWallet |

## Laptop power policy

Battery charge thresholds are managed in BIOS/firmware (vendor power settings), not in NixOS services.

This keeps charging behavior consistent regardless of OS state. Desktop session power behavior remains handled by Plasma.
