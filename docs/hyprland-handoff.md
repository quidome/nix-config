# Hyprland bring-back handoff (`bea`)

## Current state

This branch restores a minimal Hyprland path for `bea`.

Already done:
- `settings.gui = "hyprland"` support restored
- `hosts/bea/shared.nix` now sets `settings.gui = "hyprland"`
- Hyprland system module restored
- Hyprland home module restored
- terminal baseline switched to `wezterm`
- minimal WezTerm theming added
- `bea`-specific monitor/device/kanshi settings reintroduced

Key files:
- `hosts/bea/shared.nix`
- `hosts/bea/home.nix`
- `modules/shared/settings.nix`
- `modules/system/desktop/hyprland.nix`
- `modules/home/desktop/hyprland.nix`
- `modules/home/desktop/hyprland/*`
- `modules/home/programs/wezterm.nix`
- `modules/home/settings.nix`

## Validation done

Completed successfully:
- `just fmt`
- `just check`
- `nix build .#nixosConfigurations.bea.config.system.build.toplevel`

Note: this repo does not currently provide `just plan` or `just build` recipes.

## Remaining plan

### 1. Review the diff
Run:
- `rtk git status --short`
- `rtk git diff --stat`
- `rtk git diff`

Focus on:
- `hosts/bea/*`
- `modules/system/desktop/hyprland.nix`
- `modules/home/desktop/hyprland.nix`
- `modules/home/programs/wezterm.nix`

### 2. Runtime validation on `bea`
Suggested order:
1. `just check`
2. `nix build .#nixosConfigurations.bea.config.system.build.toplevel`
3. `just switch bea` only with explicit approval

### 3. First-login checks
Verify after switching:
- greetd offers/starts Hyprland
- Hyprland starts through UWSM
- WezTerm launches from mod+return
- WezTerm launches from fuzzel
- Waybar appears
- mako notifications work
- hyprlock works
- hypridle locks and resumes display correctly
- polkit prompts appear
- keyring works for desktop apps
- tray/network applet behavior is acceptable

### 4. `bea`-specific checks
Verify:
- monitor layout
- Samsung monitor disable rule still matches current display identity
- mouse handedness / scroll behavior
- kanshi behavior

If these are wrong, adjust only `hosts/bea/home.nix`.

### 5. WezTerm polish
If terminal behavior needs tuning, edit:
- `modules/home/programs/wezterm.nix`

Likely tweaks:
- font weight
- padding
- colorscheme
- SSH ergonomics
- zellij key conflicts

### 6. Optional cleanup
After runtime is good:
- trim any unused Hyprland pieces
- simplify binds if needed
- decide whether Waybar styling should stay minimal

## Suggested commit message

- `feat(bea): restore hyprland desktop with wezterm`
