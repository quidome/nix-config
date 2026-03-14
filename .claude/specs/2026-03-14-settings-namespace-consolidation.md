# Settings Namespace Consolidation

**Date:** 2026-03-14
**Status:** Completed
**Experts consulted:** Arch, Nix, Review

## Problem

The module structure mixes different patterns for defining custom options:

1. **`settings.*` namespace** - custom options under settings (swayidle, desktop/niri)
2. **`programs.*` namespace** - custom options mimicking HM structure (programs/niri, noctalia)

This inconsistency makes the codebase harder to understand. Additionally:
- Noctalia's enable is under `settings.desktop.niri.noctalia.enable`, tying it to niri
- `programs/niri/default.nix` defines `options.programs.niri.*` which could conflict with home-manager's `programs.niri`

## Solution

**Principle:** `settings.*` is for custom options that home-manager/NixOS doesn't provide. The namespace mirrors the HM/NixOS module structure.

| Scenario | Approach |
|----------|----------|
| HM/NixOS has the option | Use it directly (e.g., `programs.git.enable`) |
| HM/NixOS lacks the option | Add under `settings.*` mirroring the path |

**Options stay co-located** - each module defines its own `options.settings.*` rather than centralizing in `settings.nix`.

### Target Namespace Structure

```
settings.
├── gui                          # (shared) which desktop: none|gnome|hyprland|niri|plasma
├── preferQt                     # (shared) prefer Qt over GTK
├── authorizedKeys               # (shared) SSH public keys
├── terminal                     # (home) which terminal emulator
├── terminalFont.name            # (home) font name
├── terminalFont.size            # (home) font size
├── desktop.
│   ├── niri.enable              # enable niri desktop integration
│   └── hyprland.enable          # enable hyprland desktop integration
├── programs.
│   ├── niri.terminal            # terminal for niri keybind (HM has no such option)
│   └── noctalia.
│       ├── enable               # enable noctalia (not a standard HM module)
│       ├── enableBrightnessWidget
│       └── enableNetworkWidget
└── services.
    └── swayidle.
        ├── enable               # HM has swayidle but not these specific options
        ├── lockTimeout
        └── suspendTimeout
```

## Rationale

1. **Extension, not duplication** - `settings.*` only adds what HM/NixOS lacks
2. **Predictable namespace** - mirrors HM structure, easy to find options
3. **Co-location** - options defined alongside their implementation
4. **Noctalia independence** - `settings.programs.noctalia.*` works with any Wayland desktop

## Files Affected

### Modules to refactor:

- `modules/home/programs/noctalia/default.nix`
  - Change `options.programs.noctalia.*` → `options.settings.programs.noctalia.*`
  - Update `cfg` binding

- `modules/home/programs/niri/default.nix`
  - Change `options.programs.niri.terminal` → `options.settings.programs.niri.terminal`
  - Remove `options.programs.niri.enable` (use HM's `programs.niri.enable` instead)
  - Update `cfg` binding to use `config.programs.niri` for enable, `config.settings.programs.niri` for custom options

- `modules/home/desktop/niri.nix`
  - Remove `options.settings.desktop.niri.noctalia.enable`
  - Update references from `programs.noctalia.enable` to `settings.programs.noctalia.enable`

### Modules with reference updates:

- `modules/home/services/swayidle.nix`
  - Change `config.programs.noctalia` → `config.settings.programs.noctalia`

### Hosts to update:

- `hosts/nimbus/home.nix` - Change `settings.desktop.niri.noctalia.enable` → `settings.programs.noctalia.enable`
- `hosts/coolding/home.nix` - Change `settings.desktop.niri.noctalia.enable` → `settings.programs.noctalia.enable`
- `hosts/bea/home.nix` - Check for noctalia references

### Already correct (no changes):

- `modules/home/services/swayidle.nix` - Uses `settings.services.swayidle.*` ✓
- `modules/home/programs/alacritty.nix` - Config-only augmentation ✓
- `modules/home/programs/git.nix` - Config-only augmentation ✓

## Implementation Steps

1. **Update `modules/home/programs/noctalia/default.nix`**
   - Rename `options.programs.noctalia` → `options.settings.programs.noctalia`
   - Update `cfg = config.settings.programs.noctalia`

2. **Update `modules/home/programs/niri/default.nix`**
   - Remove custom `enable` option (rely on HM's `programs.niri.enable`)
   - Rename `options.programs.niri.terminal` → `options.settings.programs.niri.terminal`
   - Update cfg bindings

3. **Update `modules/home/desktop/niri.nix`**
   - Remove `noctalia.enable` from `options.settings.desktop.niri`
   - Change references from `programs.noctalia.*` to `settings.programs.noctalia.*`

4. **Update `modules/home/services/swayidle.nix`**
   - Change `noctalia = config.programs.noctalia` → `noctalia = config.settings.programs.noctalia`

5. **Update host configurations**
   - nimbus, coolding: `settings.desktop.niri.noctalia.enable` → `settings.programs.noctalia.enable`

6. **Test with `nix flake check`**

7. **Test with `just build` on coolding**

## Quality Criteria

- All `nix flake check` passes
- `just build` succeeds for coolding (niri + noctalia)
- No custom options under `programs.*` or `services.*` (only under `settings.*`)
- HM's native options used where available
- Consistent style: 2-space indent, `with lib;` pattern

## Risks

- **Low risk**: Option path changes are straightforward
- **Host configs need updating**: nimbus, coolding use noctalia - update simultaneously
- **No backwards compatibility needed**: Personal config, not a public module
