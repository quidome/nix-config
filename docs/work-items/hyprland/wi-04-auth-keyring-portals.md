# WI-04: Auth, keyring, and portals

Status: DONE

Spec: `docs/specs/hyprland-desktop.md`

## Goal

Provide sane desktop auth prompts, secret storage, and portal integration.

## Scope

Candidates from previous config:

- `polkit_gnome` or another Hyprland-suitable polkit agent
- `gnome-keyring`
- `libsecret`
- `seahorse`
- PAM entry for `hyprlock`
- `xdg-desktop-portal-gtk`

## Non-goals

- Do not introduce duplicate polkit agents.
- Do not add unrelated GNOME desktop components.

## Acceptance

- GUI auth prompts appear when needed.
- Secret storage works for common desktop apps.
- XDG portal behavior is sane.
- `just fmt` and `just check` pass.

## Result

Added:

- `modules/home/desktop/hyprland/polkit.nix`

Configured:

- `polkit-gnome-authentication-agent-1.service` as a systemd user service bound
  to `hyprland-session.target`.
- `services.gnome.gnome-keyring.enable = true` for Hyprland systems.
- greetd PAM integration for GNOME Keyring.
- `libsecret` and `seahorse` for secret storage tools/UI.
- `pinentry-gnome3` for graphical GPG prompts in Hyprland.

Portal notes:

- NixOS Hyprland/Wayland defaults already provide `xdg-desktop-portal-hyprland`
  and `xdg-desktop-portal-gtk`.
- Hyprland portal routing explicitly sends
  `org.freedesktop.impl.portal.Settings` to `gtk` so apps such as Firefox can
  read the dark-mode preference.
- Enabling GNOME Keyring also adds its DBus/portal integration.

Runtime checks after switch:

```sh
systemctl --user status polkit-gnome-authentication-agent-1.service
busctl --user list | grep -E 'org.freedesktop.secrets|org.gnome.keyring'
pgrep -a gnome-keyring || true
secret-tool search test test || true
```

GNOME Keyring is DBus/PAM activated in this setup; it does not provide a
`gnome-keyring-daemon.service` user unit.
