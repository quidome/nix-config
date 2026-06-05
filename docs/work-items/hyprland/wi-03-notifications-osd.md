# WI-03: Notifications and OSD

Status: DONE

Spec: `docs/specs/hyprland-desktop.md`

## Goal

Add desktop notifications and user feedback for volume/brightness changes.

## Scope

Candidates:

- `mako` for notifications
- `avizo` for volume/brightness OSD
- `libnotify` for `notify-send` testing

## Non-goals

- No large notification theming pass.
- No custom shell layer.

## Acceptance

- `notify-send test` displays a notification.
- Volume/brightness key feedback works where hardware supports it.
- Services are systemd/user-session managed where possible.
- `just fmt` and `just check` pass.

## Result

Added Hyprland-specific modules:

- `modules/home/desktop/hyprland/avizo.nix`
- `modules/home/desktop/hyprland/mako.nix`

Configured:

- `services.avizo` with minimal OSD settings.
- `services.mako` with a small bottom-right notification config.
- `libnotify` for `notify-send` testing.
- `avizo.service` bound to `hyprland-session.target`.
- `mako.service` added and bound to `hyprland-session.target`.

`just fmt` and `just check` pass. Runtime verification remains: after switch,
check `systemctl --user status avizo.service mako.service` and run
`notify-send test`.
