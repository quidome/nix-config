# WI-05: Tray and network helpers

Status: DONE

Spec: `docs/specs/hyprland-desktop.md`

## Goal

Add useful tray helpers conditionally.

## Scope

Candidates:

- `networkmanagerapplet` when NetworkManager is enabled

## Non-goals

- Do not force optional network/tray tools on all hosts.
- Do not add duplicate network managers.

## Acceptance

- Tray helpers are conditional.
- Waybar tray shows useful applets when enabled.
- `just fmt` and `just check` pass.

## Result

Configured conditional Home Manager tray helper services for Hyprland:

- `services.network-manager-applet.enable` follows
  `osConfig.networking.networkmanager.enable`.
- `xsession.preferStatusNotifierItems = true` so applets prefer Waybar-compatible
  SNI/AppIndicator mode.
- Helper services are bound to `hyprland-session.target` instead of the generic
  `graphical-session.target`.

On `nimbus`, evaluated state is:

- NetworkManager applet enabled.
- `nm-applet` starts with `--indicator`.

Runtime check after switch:

```sh
systemctl --user status network-manager-applet.service
```
