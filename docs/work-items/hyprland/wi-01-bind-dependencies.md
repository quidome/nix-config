# WI-01: Package existing bind dependencies

Status: DONE

Spec: `docs/specs/hyprland-desktop.md`

## Goal

Ensure commands referenced by current Hyprland binds are available in the session.

## Scope

Candidates:

- `grimblast` for screenshots
- `playerctl` for media keys
- `hyprlock` for lock bind
- `avizo` for `volumectl` / `lightctl`
- `thunar` for file manager bind
- optional: `wev` for input/event debugging

## Non-goals

- Do not configure lock/idle behavior here.
- Do not add notification services here.
- Do not add broad package sets from the old config.

## Acceptance

- Every command referenced by current Hyprland binds exists.
- Hyprland config remains small and focused.
- `just fmt` and `just check` pass.

## Result

Added Hyprland session packages for existing binds:

- `grimblast` for screenshots
- `playerctl` for media keys
- `thunar` for the file manager bind

Existing launcher/terminal packages remain:

- `wofi`
- `foot`

`hyprlock` is now managed by `programs.hyprlock` as part of WI-02.
`avizo` is now managed by `services.avizo` as part of WI-03.
