# WI-02: Lock and idle

Status: DONE

Spec: `docs/specs/hyprland-desktop.md`

## Goal

Bring back a clean `hyprlock` and `hypridle` setup.

## Scope

- Enable/configure `hyprlock`.
- Enable/configure `hypridle` as a systemd-managed user service when supported.
- Lock after a reasonable idle timeout.
- Turn displays off after a longer timeout.

## Non-goals

- No hardcoded private wallpaper paths from the old config.
- No complex visual lockscreen styling unless needed.

## Acceptance

- Lock command works.
- Idle lock works.
- Display off/on behavior works cleanly.
- `just fmt` and `just check` pass.

## Result

Added clean Hyprland-specific modules:

- `modules/home/desktop/hyprland/hyprlock.nix`
- `modules/home/desktop/hyprland/hypridle.nix`

Configured:

- `programs.hyprlock` with a blurred screenshot background, no private wallpaper
  path, and minimal input styling.
- `services.hypridle` bound to `hyprland-session.target`.
- idle lock after 10 minutes.
- DPMS off after 20 minutes, with resume restoring displays.
- `security.pam.services.hyprlock = {};` so unlocking can authenticate.
