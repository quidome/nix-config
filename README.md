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

Four desktops are supported via `settings.gui`: `hyprland`, `niri`, `gnome`, `plasma`.

The table below maps core desktop functionality to how each environment provides it. "built-in" means the desktop handles it natively with no extra tooling required.

| Requirement | Hyprland | Niri | GNOME | Plasma |
|---|---|---|---|---|
| **Status bar** | waybar / noctalia | waybar / noctalia | built-in | built-in |
| **App launcher** | wofi | fuzzel | Activities overlay | Kickoff |
| **Notifications** | mako / noctalia | mako / noctalia | built-in | built-in |
| **Screen lock** | hyprlock / noctalia | swaylock / noctalia | built-in | built-in |
| **Idle / sleep** | hypridle | swayidle | built-in | built-in |
| **Volume / OSD** | avizo (`volumectl`) / noctalia | avizo (`volumectl`) / noctalia | built-in | built-in |
| **Brightness / OSD** | avizo (`lightctl`) / noctalia | avizo (`lightctl`) / noctalia | built-in | built-in |
| **Wallpaper** | hyprpaper / noctalia | swaybg (`settings.programs.niri.wallpaper`) / noctalia | built-in | built-in |
| **Network management** | nm-applet | nm-applet | built-in | built-in |
| **Bluetooth management** | bluetoothctl (CLI) / noctalia | bluetoothctl (CLI) / noctalia | built-in | built-in |
| **Display layout** | kanshi | kanshi | built-in + display-configuration-switcher ext | built-in |
| **System tray** | waybar tray / noctalia | waybar tray / noctalia | appindicator extension | built-in |
| **Polkit agent** | polkit-kde-agent-1 | polkit-kde-agent-1 | built-in | built-in |
| **Screenshot** | grimblast (Print binds) | niri built-in (Print binds) | built-in | Spectacle |
| **Clipboard** | wl-clipboard | wl-clipboard | built-in | built-in |
| **XDG portals** | xdg-desktop-portal-gtk | xdg-desktop-portal-gtk | built-in | built-in |
| **Color scheme** | GTK/Qt Adwaita Dark | GTK/Qt Adwaita (light/dark) | dconf color-scheme | KDE theming |
| **Secret storage** | gnome-keyring | gnome-keyring | gnome-keyring | KWallet |

## Laptop power policy

On hosts with `laptop.enable = true`, this repo intentionally uses `services.tlp` for laptop power tuning and charge thresholds, and forces `services.power-profiles-daemon.enable = false`.

This is a deliberate policy choice to keep battery threshold behavior deterministic across laptop hosts, including Plasma systems where PowerDevil remains responsible for session-level power behavior.
