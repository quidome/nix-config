# Nix Configuration Repository

## Personal Defaults (short)
- Keep responses short.
- Show plan first, then edit.
- Minimal diffs only; no unrelated cleanup.
- Ask before risky commands.

## New Agent Startup Checklist
- Read `AGENTS.md`, `README.md`, `justfile`, and `flake.nix` first
- Inspect top-level layout and available hosts (`ls`, `hosts/`)
- Run `git-crypt status` before repo analysis or commit workflows
- Treat `.gitattributes`-protected files as off-limits; do not expose or decrypt them
- Confirm task scope and constraints with the user before making edits
- Use `just`-based validation flow: `just check` → `just plan [HOST]` → `just build [HOST]`
- Keep changes small, reviewable, and focused on requested scope

## Command Workflow (use `just`)
- Repo checks: `just check`
- Format Nix files: `just fmt`
- Dry-run host activation: `just plan [HOST]`
- Build host config: `just build [HOST]`
- Apply now: `just switch [HOST]`
- Apply on next boot: `just boot [HOST]`
- Roll back active generation: `just rollback [HOST]`
- List system generations: `just generations [HOST]`
- Build ISO images: `just iso [base|bcachefs]`
- Maintenance: `just update`, `just clean`, `just refresh`

## Validation Flow (repo-specific)
- First: `just check`
- Format Nix: `just fmt`
- Host dry-run: `just plan [HOST]`
- Host build: `just build [HOST]`

## Code Style Guidelines
- Use 2-space indentation throughout
- Keep imports at the top; follow existing ordering
- Prefer clear `let ... in` structure and descriptive names
- Define options with `mkOption` and suitable `types.*`
- Use `mkIf` / `mkDefault` for conditional/default behavior
- Keep module flow consistent: options → config → implementation
- Format with `alejandra` (via `just fmt`)

## Repository Structure
- `flake.nix` - Main entry point with inputs/outputs
- `modules/shared/` - Shared options and secret wiring
- `modules/system/` - NixOS modules (desktop, profiles, services)
- `modules/home/` - Home-manager modules (desktop, programs, services, theme)
- `hosts/{host}/` - Host-specific system/home selections and overrides
- `live-image/` - Live ISO configurations

## Desktop Environments
- Officially supported desktop: **Plasma (KDE)**
- Host desktop-specific overrides in `hosts/*/home.nix` should be gated with `lib.mkIf config.settings.gui` unless desktop-agnostic
- See `README.md` for laptop power policy details

## Security Guardrails (git-crypt)
- Treat `.gitattributes` entries as protected; do not expose contents in prompts, logs, or responses
- Before repo analysis or commit workflows, run `git-crypt status`
- Never decrypt, copy, or share protected files/keys
- If asked for protected content, respond: "I cannot access encrypted content for security reasons"
- If protected content is accidentally accessed, stop and do not reproduce it

## Extra Safety
- Never run `just switch`, `just boot`, or `just rollback` without explicit approval
- Never run destructive cleanup (`just clean`) without approval
- Run `git-crypt status` before analysis/commit workflows
- Do not expose `.gitattributes`-protected content

## Commit Workflow
- Follow `.claude/commands/commit.md` when committing is requested
- Before commit flow, run `git-crypt status` and stop if protected/encrypted files are involved
- Show planned commit groups and ask for confirmation before `git commit` (unless user says proceed immediately)
- Use Conventional Commit messages (`feat(...)`, `fix(...)`, `refactor(...)`, `chore(...)`)

## Validation
- Primary validation: `just check`
- Host dry-run check: `just plan [HOST]`
- Host build check: `just build [HOST]`
