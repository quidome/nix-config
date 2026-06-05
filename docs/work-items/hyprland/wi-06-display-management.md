# WI-06: Display management

Status: DONE

Spec: `docs/specs/hyprland-desktop.md`

## Goal

Decide and implement a clean display management approach.

## Scope

Candidates:

- `shikane`
- `kanshi`
- `wdisplays` for manual display layout

## Non-goals

- Do not run multiple automatic display profile services.
- Do not overfit to one temporary monitor setup.

## Acceptance

- One display profile tool is chosen, or this is explicitly deferred.
- Manual display layout tool is available if desired.
- `just fmt` and `just check` pass.

## Result

Chosen approach:

- `kanshi` for automatic display profiles.
- `wdisplays` for manual display layout.
- `shikane` is intentionally not enabled to avoid duplicate automatic display
  management.

Configured:

- `services.kanshi.systemdTarget = "hyprland-session.target"` for Hyprland.
- `wdisplays` in the Hyprland session package set.
- Host-local `nimbus` Kanshi profiles in `hosts/nimbus/home.nix`:
  - `internal`
  - `external-only`
  - `external-left`
  - `internal-only`

Runtime check after switch:

```sh
systemctl --user status kanshi.service
```

Follow-up fix:

- Fixed the Hyprland settings merge to use recursive merging. The previous
  shallow merge dropped core monitor/debug/general settings, including
  `debug:disable_scale_checks`, gaps, wallpaper, monitor, and window rules.
- Fixed Lua-config compatibility errors by using nested `debug.disable_scale_checks`,
  removing removed `dwindle.pseudotile`, simplifying the active border color,
  and setting `misc.disable_scale_notification = true`.
- Set `misc.force_default_wallpaper = 2` to pin Hyprland's second bundled
  default wallpaper consistently.
