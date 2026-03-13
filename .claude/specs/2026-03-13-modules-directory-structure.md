# Modules Directory Structure

**Date:** 2026-03-13
**Status:** Draft
**Experts consulted:** Arch, Nix, Review

## Problem

Top-level directories (`nixos/`, `home/`, `shared/`) clutter the repository root and the name `nixos/` is overly specific (doesn't accommodate potential nix-darwin support).

## Solution

Consolidate module directories under a new `modules/` directory with clearer naming:

```
modules/
├── system/    # Renamed from nixos/
├── home/      # Moved from home/
└── shared/    # Moved from shared/
```

## Rationale

- **Consolidation**: Groups all reusable modules under one directory
- **Naming**: `system` is generic and works for NixOS or nix-darwin
- **Clarity**: Clear separation between `modules/` (reusable) and `hosts/` (host-specific)

## Technical Notes (Nix)

- Path changes are safe - Nix imports are relative
- No evaluation order issues - module aggregation pattern unchanged
- `shared/` is imported twice (NixOS + home-manager) - this is intentional and continues to work

## Files Affected

**Directories:**
- `nixos/` → `modules/system/` - Directory rename
- `home/` → `modules/home/` - Directory move
- `shared/` → `modules/shared/` - Directory move

**Code:**
- `flake.nix` - Update 6 import paths

**Documentation:**
- `CLAUDE.md` - Update directory structure section
- `.claude/REFACTORING-PATTERNS.md` - Update path references in examples
- `.claude/skills/arch/SKILL.md` - Update settings.nix path reference
- `.claude/skills/nix/SKILL.md` - Update settings.nix path references

## Implementation Steps

1. Create `modules/` directory
2. Move directories:
   ```bash
   mkdir modules
   git mv nixos modules/system
   git mv home modules/home
   git mv shared modules/shared
   ```
3. Update `flake.nix` references:
   - Line 50: `./shared` → `./modules/shared`
   - Line 51: `./nixos` → `./modules/system`
   - Line 61: `./shared` → `./modules/shared`
   - Line 62: `./home` → `./modules/home`
   - Line 86: `./shared/secrets.nix` → `./modules/shared/secrets.nix`
   - Line 94: `./shared/secrets.nix` → `./modules/shared/secrets.nix`
4. Update documentation:
   - `CLAUDE.md` - directory structure section
   - `.claude/REFACTORING-PATTERNS.md` - example paths
   - `.claude/skills/arch/SKILL.md` - settings.nix reference
   - `.claude/skills/nix/SKILL.md` - settings.nix references
5. Test with `nix flake check`

## Quality Criteria

- All `nix flake check` passes
- `just build` succeeds for at least one host
- No orphaned references to old paths

## Risks

- **Low**: Simple rename/move with clear path updates
- Git history preserved via `git mv`
- Documentation updates are straightforward find/replace

## Review Checklist

- [ ] All `nix flake check` passes
- [ ] `just build` succeeds for at least one host
- [ ] No orphaned references to old paths (`nixos/`, `home/`, `shared/`)
- [ ] Documentation accurately reflects new structure
- [ ] Git history preserved for moved files
