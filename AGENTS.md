# Nix Configuration Repository

## Build Commands
- `just build` - Build and switch NixOS system configuration
- `just build-home` - Build and switch home-manager configuration
- `just update` - Update flake.lock and nix-index package cache
- `just gc` - Run Nix garbage collection for user and system
- `just all` - Complete update, GC, and build cycle

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
- `shared/` - Common NixOS and home-manager modules
- `hosts/{host}/` - Host-specific configurations
- `home/` - Home-manager program and service configurations
- `nixos/` - NixOS system-level configurations
- Use relative imports from flake root: `./shared` `./hosts/${host}`

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

## Testing
No formal test framework. Validate configurations with:
- `nix flake check` - Validate flake syntax
- `nixos-rebuild build --flake .#host` - Dry run build
- `home-manager build --flake .#user@host` - Dry run home config
