# Hyprland Desktop Spec

## Goal

Make the Hyprland session comfortable and complete while keeping the config small,
modular, and easy to review.

## Reference

The example setup is the current working tree at `~/tmp/nix-config/`. Treat it
as a source of ideas, not as config to copy wholesale. Prefer clean, minimal
modules in this repository.

Do not inspect git history in `~/tmp/nix-config/` unless explicitly requested;
use the current file state only.

Useful current areas in that repo:

- `modules/home/desktop/hyprland.nix`
- `modules/home/programs/waybar.nix`
- `modules/home/programs/hyprlock.nix`
- `modules/home/services/hypridle.nix`
- `modules/home/services/mako.nix`
- `modules/home/theme/default.nix`
- `modules/system/desktop/hyprland.nix`

## Current state

- Hyprland launches.
- Apps can be launched.
- Waybar is configured in a small Hyprland-specific module.
- Waybar is intended to run as a Home Manager/systemd user service, but runtime
  startup under Hyprland/UWSM still needs verification.
- Gaps are reduced.
- Hyprland's second bundled default wallpaper is pinned with
  `misc.force_default_wallpaper = 2`.
- Animations are disabled.

## Constraints

- Keep diffs minimal and focused.
- Do not copy the old config wholesale.
- Prefer one small module per concern when config grows.
- Avoid Noctalia or other large/fancy shell layers for now.
- Validate with `just fmt` and `just check`.
- Do not run `just switch`, `just boot`, or rollback commands without approval.

## Modern Linux/session principles

Prefer modern, supervised desktop-session integration where practical:

- Run long-lived session components as systemd user services when supported.
- Launch desktop apps through the systemd-aware launcher path, e.g. `uwsm app --`.
- Keep Hyprland `exec-once` minimal; prefer Home Manager/systemd-managed services.
- Use XDG portals for desktop integration instead of ad hoc per-app workarounds.
- Prefer declarative Nix/Home Manager configuration over shell startup scripts.
- Keep service dependencies explicit and avoid duplicate session managers.
- Use conditional integration for optional services, such as tray helpers for
  NetworkManager.

## Desired end state

Hyprland should provide the basics expected from a desktop session:

- launcher
- systemd-managed bar
- notifications
- lock screen
- idle handling
- screenshots
- volume/brightness/media keys
- file manager
- auth prompts / polkit
- secrets/keyring support where needed
- sane XDG portal integration
- optional display/tray helpers

## Work items

### WI-00: Verify Waybar systemd launch

Ensure Waybar is launched and supervised by the user systemd session, not by a
Hyprland `exec-once` workaround.

Acceptance:

- Evaluated config generates a `waybar.service` user unit.
- Runtime checks show `waybar.service` active after Hyprland login.
- The service has the needed Wayland/session environment.
- Hyprland keeps no Waybar-specific `exec-once` unless systemd launch is proven
  unsuitable.

### WI-01: Package existing bind dependencies

Add only the tools referenced by current Hyprland binds/config.

Candidates:

- `grimblast` for screenshots
- `playerctl` for media keys
- `hyprlock` for lock bind
- `avizo` for `volumectl` / `lightctl`
- `thunar` for file manager bind
- optional: `wev` for debugging input/events

Acceptance:

- Every command referenced by Hyprland binds exists in the session.
- No services are enabled in this item except what packages require.

### WI-02: Lock and idle

Bring back a clean `hyprlock` + `hypridle` setup.

Acceptance:

- Lock command works.
- Idle locks after a reasonable timeout.
- Display powers off after a longer timeout and resumes cleanly.
- No hardcoded private wallpaper paths from the old config.

### WI-03: Notifications and OSD

Add notification and feedback services.

Candidates:

- `mako` for notifications
- `avizo` for volume/brightness OSD
- `libnotify` for `notify-send` testing

Acceptance:

- `notify-send test` displays a notification.
- Volume/brightness key feedback works if hardware supports it.

### WI-04: Auth, keyring, and portals

Add session integration for desktop auth and secrets.

Candidates from previous config:

- polkit agent, preferably `polkit_gnome` for Hyprland
- `gnome-keyring`
- `libsecret`
- `seahorse`
- PAM entry for `hyprlock`
- `xdg-desktop-portal-gtk`

Acceptance:

- GUI auth prompts appear when needed.
- Secret storage works for common desktop apps.
- Screen sharing/file chooser portal behavior is sane.

### WI-05: Tray and network helpers

Add tray helpers conditionally where the relevant services are enabled.

Candidates:

- `networkmanagerapplet` when NetworkManager is enabled
Acceptance:

- Tray helpers do not install/start unnecessarily.
- Waybar tray shows useful applets when enabled.

### WI-06: Display management

Decide whether to bring back display profile tooling.

Candidates:

- `shikane` or `kanshi`
- `wdisplays` for manual display layout

Acceptance:

- One display profile tool is chosen, or this is explicitly deferred.
- No duplicate display management services.

### WI-07: Theming polish

Apply minimal GTK/Qt defaults for Hyprland apps.

Candidates from previous config:

- GTK dark preference
- Adwaita or Catppuccin-compatible theme choices
- Qt platform/theme defaults

Acceptance:

- GTK/Qt apps are readable and consistent enough.
- No large theming framework is introduced.

### WI-08: Documentation cleanup

Update docs once Hyprland reaches a stable baseline.

Acceptance:

- README desktop table reflects Hyprland support if it remains supported.
- This spec is updated with completed/deferred work items.
