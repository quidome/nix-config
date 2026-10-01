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

## Host settings

Each host sets its settings in `hosts/<host>/shared.nix`.
The flake imports this file in both the system and the home-manager config, so every host must have one (it can be `{}`).

```nix
settings = {
  gui = "plasma";
  formFactor = "laptop";
  roles = {
    dev.enable = true;
    personal.enable = true;
  };
};
```

### `gui`

The graphical session: `"none"`, `"niri"` or `"plasma"` (default).
Any value other than `"none"` also enables the graphical base: fonts, PipeWire, Flatpak and `wl-clipboard`.

The niri session is minimal. It has no login manager, so start it with `niri-session` from a console.

### `formFactor`

The kind of machine: `"laptop"`, `"desktop"` (default) or `"server"`.

| Form factor | Enables |
| --- | --- |
| desktop, laptop | NetworkManager, bluetooth |
| laptop | power-profiles-daemon, upower, fwupd |

All of these use `lib.mkDefault`.
A desktop module that needs something else turns the service off with a plain assignment, for example `services.power-profiles-daemon.enable = false;`.

### `roles`

Optional groups of software. All are off by default.

| Role | Contents |
| --- | --- |
| `dev` | git, kubernetes and devops tools, linters, Java, coding agents, direnv, jujutsu; with a GUI also VSCodium, Zed and Emacs |
| `personal` | Syncthing; with a GUI also browser, mail, office, chat, printing and Avahi |
| `media` | kdenlive, Blender, OrcaSlicer (GUI only) |
| `gaming` | OpenTTD, 0 A.D. (GUI only) |

Software that only one host uses stays in that host's `configuration.nix`.

### Terminal multiplexer

The default terminal multiplexer is Zellij.
Set `programs.zellij.enable = false` per host/user if you want no multiplexer.

## Laptop power policy

Battery charge thresholds are managed in BIOS/firmware (vendor power settings), not in NixOS services.

This keeps charging behavior consistent regardless of OS state.
