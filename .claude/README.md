# Claude Code Refactoring Commands

This directory contains custom slash commands designed to help refactor this NixOS configuration repository systematically and safely.

## Available Commands

### Planning & Analysis

- **`/refactor-plan`** - Create a comprehensive, phased refactoring plan
  - Start here for a complete refactoring workflow
  - Creates prioritized todo list with all tasks
  - Defines phases: Safe Automation → Consolidation → Settings → Organization

- **`/refactor-analyze`** - Comprehensive analysis of refactoring opportunities
  - Identifies duplicates, organization issues, settings opportunities, style issues
  - Provides structured report with priorities
  - Creates todo list of identified issues

### Targeted Refactoring

- **`/refactor-duplicates`** - Find and consolidate duplicate code
  - Searches for repeated patterns across modules
  - Proposes extraction to shared modules
  - Shows before/after examples

- **`/refactor-settings`** - Improve the settings system
  - Analyzes current settings usage
  - Proposes new settings to reduce hardcoding
  - Suggests settings system enhancements

- **`/refactor-module <path>`** - Refactor a specific module
  - Applies best practices to one module
  - Improves organization and style
  - Maintains functionality

- **`/refactor-style`** - Check and fix code style issues
  - Scans for style violations (indentation, imports, etc.)
  - Generates detailed report
  - Can auto-fix issues with approval

### Validation

- **`/refactor-validate`** - Validate refactoring changes
  - Runs `nix flake check`
  - Tests builds for all hosts
  - Verifies security (encrypted files unchanged)
  - Confirms style compliance

## Recommended Workflow

### 1. Create a Plan
```
/refactor-plan
```
This creates a comprehensive refactoring plan with phased tasks.

### 2. Start with Analysis
```
/refactor-analyze
```
Get a detailed picture of what needs refactoring.

### 3. Execute by Phase

**Phase 1: Safe Automation**
```
/refactor-style
/refactor-validate
```

**Phase 2: Consolidation**
```
/refactor-duplicates
/refactor-validate
```

**Phase 3: Settings Enhancement**
```
/refactor-settings
/refactor-validate
```

**Phase 4: Module-by-Module**
```
/refactor-module <path/to/module>
/refactor-validate
```

### 4. Always Validate
Run `/refactor-validate` after each refactoring session before committing.

## Safety Features

All commands respect these constraints:
- **Never read or modify encrypted files** (listed in .gitattributes)
- Maintain backward compatibility
- Follow code style from CLAUDE.md
- Preserve all functionality
- Validate before committing

## Tips

1. **Start small**: Begin with `/refactor-style` for quick, low-risk wins
2. **Validate often**: Run `/refactor-validate` after each significant change
3. **Use git**: Commit after each phase for easy rollback
4. **Review changes**: Always review generated code before applying
5. **Test builds**: Run `just check-all` or `nix flake check` frequently

## Integration with Existing Commands

These refactoring commands work alongside your existing `justfile` commands:

```bash
just check-all    # Validate all configurations
just build        # Build and switch
just gc           # Garbage collection
nix flake check   # Syntax validation
```

## Customization

To add new refactoring commands:
1. Create a new `.md` file in `.claude/commands/`
2. Follow the existing command structure
3. Include safety constraints and validation steps
4. Update this README

## Support

For issues with these commands:
- Check CLAUDE.md for repository-specific guidelines
- Review .gitattributes to understand encrypted files
- Consult flake.nix to understand the mkHost architecture
- Ask Claude Code: "How do I use the /refactor-X command?"
