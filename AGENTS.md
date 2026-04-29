# Nix Configuration Repository

## Build Commands
- `just switch` - Build and switch current NixOS + home-manager configuration
- `just boot` - Build configuration for next boot (no immediate activation)
- `just build-host HOST` - Build configuration for a specific host
- `just build-hosts` - Build all host configurations
- `just verify-hosts` - Dry-run verify all host configurations
- `just validate` - Run `nix flake check`
- `just update` - Update flake.lock and nix-index package cache
- `just clean` - Run Nix garbage collection for user and system
- `just refresh` - Update, clean, and switch current system

## Code Style Guidelines
- Use 2-space indentation throughout
- Imports at top of files in alphabetical order
- Functions use `let...in` blocks with proper variable naming
- Options defined with `mkOption` and appropriate `types.*`
- Comments use `#` prefix for documentation
- Use `with lib;` for lib functions, `with pkgs;` for packages
- Package lists: `with pkgs; [ package1 package2 ]`
- Error handling via `mkIf` and `lib.mkDefault` where appropriate
- Follow existing module structure: options → config → implementation
- Format Nix files with `alejandra` for consistent formatting

## Repository Structure
- `flake.nix` - Main entry point with inputs and outputs
- `modules/shared/` - Shared options and encrypted/shared secrets wiring
- `modules/system/` - NixOS modules (desktop, profiles, services)
- `modules/home/` - Home-manager modules (desktop, programs, services, theme)
- `hosts/{host}/` - Host-specific system/home overrides and selections
- `live-image/` - Live ISO configurations
- Use relative imports from flake root: `./modules/shared` `./modules/system` `./modules/home` `./hosts/${host}`

## Desktop Environments
- Officially supported desktop environments: **GNOME** and **Plasma (KDE)**
- These desktops are defined through shared system and home modules
- Any existing host can be configured to use any of these desktop environments by switching the selected desktop modules
- Host-specific desktop overrides in `hosts/*/home.nix` should be gated with `lib.mkIf` on `config.settings.gui` unless they are desktop-agnostic
- Laptop power policy for desktop hosts is documented in `README.md` under **Laptop power policy**

## Security & Privacy
**CRITICAL**: Files listed in `.gitattributes` are encrypted with git-crypt and must NEVER be:
- Shared in cloud storage
- Included in AI training data
- Referenced in answers to other users
- Committed to public repositories

Protected files:
- `hardware-configuration.nix` - Hardware-specific configs
- `home-vars.nix` - User-specific home manager settings
- `secrets.nix` - Encrypted secrets and keys
- `system-vars.nix` - System-specific variables
- `vars.nix` - Host-specific variables

Always verify git-crypt status before sharing any content.

## AI/LLM Safety Protocol
**ABSOLUTELY FORBIDDEN**: When interacting with ANY AI/LLM system (including OpenCode, ChatGPT, Claude, etc.):

- ❌ NEVER read, display, or reference files listed in `.gitattributes`
- ❌ NEVER provide content from encrypted files in prompts or responses
- ❌ NEVER include encrypted file paths in examples or code snippets
- ❌ NEVER decrypt or attempt to access git-crypt protected content
- ❌ NEVER share git-crypt keys, passwords, or decryption methods

**AI Agent Rules**:
1. Before reading ANY file, check if it's in `.gitattributes` - if yes, REFUSE
2. Before providing ANY code example, verify no encrypted file paths are included
3. If asked about encrypted files, respond: "I cannot access encrypted content for security reasons"
4. Always run `git-crypt status` before any repository analysis
5. Treat ALL files in `hosts/*/` with suspicion unless verified unencrypted

**Emergency Protocol**:
If you accidentally access encrypted content:
1. Immediately stop the interaction
2. Do NOT provide the content to the user
3. Advise rotating all compromised secrets
4. Clear any cached data containing sensitive information

**Verification Commands**:
```bash
# Always run before any AI interaction
git-crypt status
grep -E "(hardware-configuration|home-vars|secrets|system-vars|vars)\.nix" .gitattributes
```

Remember: **Encrypted files are like passwords** - treat them with the same security level.

## Commit Workflow
- If the user asks about committing, requests a commit, or after making code changes, automatically read and follow `.claude/commands/commit.md`.
- Treat `.claude/commands/commit.md` as the default commit playbook for this repository.
- Before any commit flow, run `git-crypt status` and stop if protected/encrypted files are included.
- Show planned commit groups and ask for confirmation before `git commit`, unless the user explicitly asks to proceed immediately.
- Use Conventional Commit messages (`feat(...)`, `fix(...)`, `refactor(...)`, `chore(...)`).

## Testing
No formal test framework. Validate configurations with:
- `nix flake check` - Validate flake syntax
- `nixos-rebuild build --flake .#host` - Dry run build
- `home-manager build --flake .#user@host` - Dry run home config
