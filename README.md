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

Two desktops are supported via `settings.gui`: `gnome`, `plasma`.

The table below maps core desktop functionality to how each environment provides it. "built-in" means the desktop handles it natively with no extra tooling required.

| Requirement | GNOME | Plasma |
|---|---|---|
| **Status bar** | built-in | built-in |
| **App launcher** | Activities overlay | Kickoff |
| **Notifications** | built-in | built-in |
| **Screen lock** | built-in | built-in |
| **Idle / sleep** | built-in | built-in |
| **Volume / OSD** | built-in | built-in |
| **Brightness / OSD** | built-in | built-in |
| **Wallpaper** | built-in | built-in |
| **Network management** | built-in | built-in |
| **Bluetooth management** | built-in | built-in |
| **Display layout** | built-in + display-configuration-switcher ext | built-in |
| **System tray** | appindicator extension | built-in |
| **Polkit agent** | built-in | built-in |
| **Screenshot** | built-in | Spectacle |
| **Clipboard** | built-in | built-in |
| **XDG portals** | built-in | built-in |
| **Color scheme** | dconf color-scheme | KDE theming |
| **Secret storage** | gnome-keyring | KWallet |

## Laptop power policy

On hosts with `laptop.enable = true`, this repo intentionally uses `services.tlp` for laptop power tuning and charge thresholds, and forces `services.power-profiles-daemon.enable = false`.

This is a deliberate policy choice to keep battery threshold behavior deterministic across laptop hosts, including Plasma systems where PowerDevil remains responsible for session-level power behavior.
