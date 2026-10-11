# Technical spec: Secret management

**Status**: approved
**Size**: story
**Change**: docs/changes/2026-10-11-secret-management/
**Date**: 2026-10-11

## Objective
Give the operator one written rule for secret, private, public and identity values, a leak guard
in the project checks that stops a secret in a plain file, and one place for the temporary
initial password hash.

## Requirements summary
From `functional.md` (approved 2026-10-11, two spec review rounds):

- **Story 1 – a rule for every value.** New living document `docs/product/secrets.md` with:
  - four classes, each with definition, examples from this repository, and where it lives:
    - **secret** (gives access when known): never in the repository, because the whole
      repository goes into the Nix store, decrypted, on every machine that builds it. For now a
      secret is a file made by hand on the host, with the step written down. One exception: the
      temporary initial password hash, in an encrypted file.
    - **private** (not secret, not wanted public: email address, host names, network names,
      authorized SSH public keys – their comments name users and hosts): encrypted with git-crypt;
      may be in the Nix store.
    - **public** (everything else, including the generated hardware configuration and the
      username): plain text. Public values may stay in an encrypted file that they share with
      private values.
    - **identity** (the operator's private keys and accounts: private SSH and GPG keys, password
      manager, browser sign-in, device pairing): never in the repository; hand work. Public SSH
      keys are not identity.
  - the known, temporary gap in core value 3: a host secret is a hand-made file, so a rebuild of
    such a host needs one step more than the identity steps; the host secret change closes it;
  - install images may hold private values, never secrets, and are not published;
  - edge cases: a value in two classes takes the stricter class; a value with no clear class is
    private until `/vision` extends the rule;
  - the class of each value that exists now (table in `functional.md`, Context).
  - `SECURITY.md` keeps only a pointer and the steps after a leak; `AGENTS.md` and
    `docs/architecture.md` point to the document; `AGENTS.md` keeps its own agent guardrails.
- **Story 2 – one place for the initial password.** `initialHashedPassword` is defined only in
  `modules/system/secrets.nix` (for the operator and `root`); the copy in `hosts/truce/vars.nix`
  is removed. Same value on every host; builds pass.
- **Story 3 – leak guard.** A check in `just verify` fails when a plain (not git-crypt) tracked or
  staged file holds a password hash or a private key; it names file, line and kind, never the
  value; it skips encrypted files and public keys; a documented mark allows one line;
  `scripts/security-check.sh` is removed.

Confirmed with the operator during Design (2026-10-11): the operator edits the encrypted
`hosts/truce/vars.nix` by hand (Claude may not read or edit encrypted files); the leak guard is a
separate flake check, not part of `lint`; age secret keys are also detected.

## Current state
- `flake.nix`: `checks.${system}.lint` runs alejandra, statix and deadnix with `cd ${./.}` in a
  `pkgs.runCommand`. `just check` runs `nix flake check`; `just verify` runs fmt, lint and check.
- `${./.}` in a git flake is a copy of the tracked and staged files, without `.git`; with the
  repository unlocked, git-crypt files are plain text in that copy.
- `.gitattributes`: `home-vars.nix`, `secrets.nix`, `system-vars.nix`, `vars.nix`, each
  `filter=git-crypt diff=git-crypt`, patterns without a slash.
- Existing pattern for a shell program: `modules/home/desktop/desktop-reset.nix` uses
  `pkgs.writeShellApplication` with `text = builtins.readFile ./desktop-reset.sh`.
- `scripts/security-check.sh`: outdated, run by nothing; only `SECURITY.md` mentions it.
- `SECURITY.md`: outdated public policy (lists `hardware-configuration.nix` as protected).
- `AGENTS.md`, section "Security Guardrails (git-crypt)": agent rules; no pointer to a rule
  document.
- `docs/architecture.md`, "Patterns to follow": "Secrets only in git-crypt files (…)".
- `modules/system/secrets.nix` (encrypted): `initialHashedPassword` for `root` and the operator.
- `hosts/truce/vars.nix` (encrypted): a `let` binding `initialHashedPassword` (with a comment
  above it) used by a `createUser` helper through
  `inherit createHome isNormalUser shell initialHashedPassword;`.

## Steps

### Step 1: Leak guard and its tests
- **Goal**: `just verify` fails on a secret in a plain file and passes on the repository now.
- **Changes**:
  - New `scripts/leak-guard.sh` (argument: the folder to check). Behaviour:
    1. Read `.gitattributes` in that folder; take the first field of each non-comment line
       with `filter=git-crypt` as an encrypted pattern. No file: no encrypted patterns.
    2. Walk all files (`find -print0`, sorted; skip `.git/`). Skip a file when a pattern
       without `/` matches its file name, or a pattern with `/` (leading `/` removed) matches its
       path, as bash glob.
    3. In each other text file (`grep -I`), find lines that match:
       - `password hash`: `\$(1|2[abxy]?|5|6|7|y|gy)\$[./A-Za-z0-9]`
       - `private key`: `-----BEGIN ([A-Z0-9]+ )*PRIVATE KEY( BLOCK)?-----`
       - `age secret key`: `AGE-SECRET-KEY-1[0-9A-Z]{10,}`
    4. Skip lines that contain `leak-guard: allow`.
    5. For each hit, collect `  <path>:<line>  <kind>` (line number only – never the text).
    6. With hits: print `leak guard: possible secret in a plain file` and the hits to stderr,
       exit 1. Else exit 0 with no output.
  - New `scripts/leak-guard-test.sh` (argument: the leak-guard program). Makes fixtures in a
    temporary folder at run time and checks exit code and output for each test below. Secret-like
    strings are assembled from parts at run time (for example `d='$'` then `"${d}6${d}..."`), so
    the test file itself never matches the guard.
  - `flake.nix`, next to `lint`: build `leakGuard` with `pkgs.writeShellApplication`
    (`name = "leak-guard"`, `runtimeInputs = [coreutils findutils gawk gnugrep]`,
    `text = builtins.readFile ./scripts/leak-guard.sh`) and add:
    - `checks.${system}.leak-guard`: runs `leak-guard ${./.}`, then `touch $out`.
    - `checks.${system}.leak-guard-test`: runs `leak-guard-test.sh` with the `leakGuard`
      program, then `touch $out`.
- **Tests** (in `leak-guard-test.sh`, each in a fresh temporary folder):
  1. One clean `.nix` file → exit 0, no output.
  2. A plain file with a crypt `$6$` hash in quotes on line 3 → exit 1; output has
     `file.nix:3  password hash`; output does not contain the hash text.
  3. The same file, named `secrets.nix`, with `.gitattributes` line
     `secrets.nix filter=git-crypt diff=git-crypt` → exit 0.
  4. The same, in a subfolder `a/b/secrets.nix` (pattern without slash) → exit 0.
  5. A pattern with a slash, `hosts/x/keep.nix filter=git-crypt`, and the hash in
     `hosts/x/keep.nix` → exit 0; the same hash in `hosts/y/keep.nix` → exit 1.
  6. An OpenSSH private key header line → `private key`; a PGP private key block header line →
     `private key`.
  7. An age secret key line → `age secret key`.
  8. An `ssh-ed25519 AAAA…` public key line → exit 0.
  9. The hash line with `# leak-guard: allow` on the same line → exit 0.
  10. A binary file that contains a hash → exit 0.
  11. A `$y$` and a `$2b$` hash → `password hash` each.
- **Integration**: `nix flake check` passes on the repository (guard and tests). Then a
  temporary plain file with a fake hash, staged with `git add -N` (intent to add), makes
  `nix flake check` fail with the file name; the file is removed afterwards and the check passes
  again.

### Step 2: The rule and the old documents
- **Goal**: one written rule; no outdated rule or check left.
- **Changes**:
  - New `docs/product/secrets.md` (product template: Purpose, Behaviour, Errors and limits,
    Interface) with all points of Story 1 above, and the leak guard (what it finds, the allow
    mark, its limits: no pattern for a bare base64 key such as a WireGuard key; it does not run on
    a commit without `just verify`).
  - `SECURITY.md`: replace with a short page – where the rule is (`docs/product/secrets.md`), and
    the steps after a leak: rotate the leaked secret; a leak of the git-crypt key exposes every
    encrypted file in the whole git history; a value that was ever pushed as plain text stays
    public.
  - Remove `scripts/security-check.sh`.
  - `AGENTS.md`, "Security Guardrails (git-crypt)": add one line that points to
    `docs/product/secrets.md` for the classes; keep all agent rules.
  - `docs/architecture.md`: the git-crypt pattern line points to `docs/product/secrets.md`;
    "Checks" names the `leak-guard` check.
  - Write examples in documents so they never match the guard: prefixes as `$6$` followed by a
    backtick; key block headers only described in words.
- **Tests**:
  - `just verify` passes (the guard reads the new documents too).
  - `grep -rn "security-check" --exclude-dir=.git .` finds hits only in `docs/changes/`.
  - Each value in the Context table of `functional.md` has a class in `secrets.md` (manual check
    by the engineer against the table).

### Step 3: One place for the initial password (operator edit)
- **Goal**: `initialHashedPassword` is set only in `modules/system/secrets.nix`.
- **Before the edit** (Claude): record the store paths of `nimbus`, `bea` and `truce`
  (`nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.outPath`).
- **Changes** (operator, in `hosts/truce/vars.nix`):
  1. In the `let` block, remove the comment above `initialHashedPassword` and the line
     `initialHashedPassword = "…";`.
  2. In `createUser`, change `inherit createHome isNormalUser shell initialHashedPassword;` to
     `inherit createHome isNormalUser shell;`.
  3. Nothing else (the commented-out users stay).
- **Tests**:
  - The store paths of `nimbus`, `bea` and `truce` are the same as before the edit (same value,
    now from one place). No value is shown.
  - The operator runs `grep -c initialHashedPassword hosts/truce/vars.nix` → `0`.
  - `just verify` passes (deadnix finds no unused binding).

## Decisions
| Decision | Reason | Decision record? |
|----------|--------|------------------|
| git-crypt stays for private values and the temporary hash; the tool for host secrets is chosen in the host secret change | Only one weak secret now; a new tool is worth it when real host secrets come | yes – `0002-git-crypt-until-host-secrets` (written at Close) |
| Leak guard as its own flake check, built with `writeShellApplication` | Clear failure message; `lint` stays as it is; reuses the `desktop-reset` pattern and gets shellcheck | no |
| The guard reads `.gitattributes`, not `git-crypt` | Inside `nix flake check` there is no git and no git-crypt | no – documented in `secrets.md` |
| Fixtures assembled at run time | The test file must not trip the guard | no – comment in the test |
| Operator edits encrypted files; Claude checks only store paths | Claude may not read or edit encrypted files | no – `AGENTS.md` |

## Not in scope
- The WireGuard key, a tool for host secrets, key rotation, key loss recovery.
- A git pre-commit hook.
- Moving public values out of encrypted files.
- The commented-out users in `hosts/truce/vars.nix`.
- Cleaning git history.
- A `just` recipe for the guard (it runs through `nix flake check`).

## Test plan
- **Existing tests that must still pass**: `just verify` (alejandra, statix, deadnix,
  `nix flake check`); builds of `nimbus`, `bea`, `truce`.
- **New tests**: `leak-guard-test` flake check (11 cases, Step 1); the integration check with an
  intent-to-add file (Step 1); store path equality (Step 3).
- **No real-host step**: nothing changes in the built systems.

## Compatibility and performance
- Built systems do not change (Step 3 is proven by equal store paths).
- `nix flake check` runs two more small checks; the guard reads every file in the repository
  once – well under a second for this size.
- A commit that adds a plain file with a hash-like or key-like line now fails `just verify`;
  the allow mark is the documented way out for a false alarm.

## Progress
- [ ] Step 1
- [ ] Step 2
- [ ] Step 3
- [ ] All checks pass

## Deviations
None. Stricter reading of Story 3, agreed with the operator: the guard also detects age secret
keys (a private key in one line), next to password hashes and private key blocks.

## Review findings
