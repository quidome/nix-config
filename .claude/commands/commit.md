---
description: Analyze working tree and create one or more well-scoped commits
argument-hint: [optional message or intent]
allowed-tools: Bash(git status, git diff, git add, git commit), Read, Edit
---

Create clean, reviewable commits from the current working tree.

## Goals
- Prefer small, functional commits.
- Split unrelated changes into separate commits.
- Use concise Conventional Commit messages.
- Never include encrypted files from `.gitattributes`.

## Safety Rules
1. Run `git-crypt status` first.
2. If any staged/changed file is encrypted or matches protected names (`hardware-configuration.nix`, `home-vars.nix`, `secrets.nix`, `system-vars.nix`, `vars.nix`), stop and report.
3. Show planned commit groups before committing.
4. Ask for confirmation before running `git commit` unless the user explicitly asked to proceed immediately.

## Procedure
1. Inspect:
   - `git status --short`
   - `git diff --name-only`
   - `git diff` (only as needed)
2. Group files by intent/functionality (example: flake packaging vs module enablement).
3. Propose commit plan:
   - Commit 1: files + message
   - Commit 2: files + message
4. After confirmation, execute per group:
   - `git add <files>`
   - `git commit -m "<type(scope): message>"`
5. Print result:
   - commit hashes
   - messages
   - remaining `git status --short`

## Commit message style
Use Conventional Commits:
- `feat(scope): ...`
- `fix(scope): ...`
- `refactor(scope): ...`
- `chore(scope): ...`

Keep subject imperative and ≤72 chars.

## If a single commit is better
If all changes are tightly related, explain why and create one commit.

## Output format
- Plan
- Confirmation question (if needed)
- Executed commits
- Final repo status
