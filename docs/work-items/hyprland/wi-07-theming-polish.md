# WI-07: Theming polish

Status: DONE

Spec: `docs/specs/hyprland-desktop.md`

## Goal

Make GTK/Qt apps readable and reasonably consistent in Hyprland.

## Scope

Candidates from previous config:

- GTK dark preference
- GTK font/theme defaults
- Qt platform/theme defaults
- Catppuccin-compatible choices where simple

## Non-goals

- No large theming framework.
- No Noctalia.
- No unrelated app-specific theming.

## Acceptance

- Common GTK/Qt apps look acceptable.
- Settings are declarative.
- `just fmt` and `just check` pass.

## Result

Configured minimal Hyprland theming:

- GNOME/GTK color-scheme preference follows `settings.theme`.
- GTK uses Noto Sans and Adwaita/Adwaita Dark.
- Qt uses the Adwaita platform theme and light/dark Adwaita style.
- GSettings schema paths are available to the session.

Catppuccin integrations enabled when the matching program/service is enabled:

- `waybar`
- `mako`
- `hyprlock` with Catppuccin default Hyprlock config disabled, keeping our
  small lockscreen config.

Waybar CSS now consumes Catppuccin colors via the generated import.
