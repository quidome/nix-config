# WI-00: Verify Waybar systemd launch

Status: DONE

Spec: `docs/specs/hyprland-desktop.md`

## Goal

Ensure Waybar is launched and supervised by the user systemd session, not by a
Hyprland `exec-once` workaround.

## Current notes

Runtime inspection showed Waybar is systemd-managed, but the previous generic
`graphical-session.target` startup could hit `start-limit-hit` after a display
restart with `cannot open display`.

The config now targets Hyprland's Home Manager session target:

- `WantedBy` includes `hyprland-session.target`
- `PartOf` includes `hyprland-session.target`
- `After` includes `hyprland-session.target`
- `ConditionEnvironment = "WAYLAND_DISPLAY"`

Applied runtime verification passed: `waybar.service` is active and bound to
`hyprland-session.target` with the expected Wayland/Hyprland user environment.

## Scope

- Verify the generated `waybar.service` unit.
- Verify runtime status after logging into Hyprland.
- If needed, adjust Home Manager Waybar systemd target/settings.
- Keep Hyprland `exec-once` free of Waybar unless systemd launch is unsuitable.

## Suggested runtime checks

After applying the config and logging into Hyprland:

```sh
systemctl --user status waybar.service
systemctl --user show-environment | grep -E 'WAYLAND_DISPLAY|XDG_CURRENT_DESKTOP|HYPRLAND_INSTANCE_SIGNATURE'
systemctl --user status graphical-session.target
systemctl --user status tray.target
```

## Non-goals

- Do not change Waybar layout/style here.
- Do not add unrelated desktop services here.

## Acceptance

- `waybar.service` is active after Hyprland login.
- Waybar starts without Hyprland `exec-once`.
- Missing environment/target issues are documented or fixed.
- `just fmt` and `just check` pass if Nix files change.
