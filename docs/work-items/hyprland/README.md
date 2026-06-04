# Hyprland Work Items

Source spec: `docs/specs/hyprland-desktop.md`

Suggested order:

1. `wi-00-waybar-systemd.md`
2. `wi-01-bind-dependencies.md`
3. `wi-02-lock-idle.md`
4. `wi-03-notifications-osd.md`
5. `wi-04-auth-keyring-portals.md`
6. `wi-05-tray-network.md`
7. `wi-06-display-management.md`
8. `wi-07-theming-polish.md`
9. `wi-08-docs-cleanup.md`

Guidelines:

- Keep each work item atomic.
- Validate code changes with `just fmt` and `just check`.
- Prefer systemd user services and `uwsm app --` where practical.
- Use the current working tree at `~/tmp/nix-config/` as an example source, not
  something to copy wholesale.
- Do not inspect git history in `~/tmp/nix-config/` unless explicitly requested.
