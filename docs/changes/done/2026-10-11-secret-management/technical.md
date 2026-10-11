# Technical spec: Secret management

**Status**: done
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
- [x] Step 1
- [x] Step 2
- [x] Step 3
- [x] All checks pass

Results (2026-10-11):
- Step 1, integration: a plain `modules/system/leak-test.nix` with a fake hash, staged with
  `git add -N`, made the `leak-guard` check fail with `modules/system/leak-test.nix:2  password
  hash` and no value; after removal the check passed. Run again after the R1/R2 fixes, same result.
- Step 3: store paths of `nimbus`, `bea` and `truce` before and after the operator's edit are
  equal (`nix eval --raw ….toplevel.outPath`, compared with `diff`). The operator's first edit left
  the line in the `let` block; the operator removed it before any check ran (no value shown).
  `just verify` passes (no unused binding).

## Deviations
None. Stricter reading of Story 3, agreed with the operator: the guard also detects age secret
keys (a private key in one line), next to password hashes and private key blocks.

After the build and acceptance reviews (2026-10-11, agreed with the operator):
- The guard stops with exit 2 on a `.gitattributes` rule it cannot follow exactly (wildcard in a
  pattern with a slash; a rule that turns the filter off; a nested `.gitattributes` that does more
  than turn the filter off for its whole folder). A folder with such a filter-off file (git-crypt's
  own `.git-crypt/`) is checked in full. Four new tests.
- The password hash pattern also finds `$apr1$` and `$argon2id$`, `$argon2i$`, `$argon2d$`; one
  new test. `secrets.md` lists the prefixes as the full set.
- After build review round 2 (agreed with the operator): the guard also stops on any other
  filter rule (`filter=…` other than git-crypt, a bare `filter`), on a macro line, and when it
  cannot read a file. Three new tests.
- The leak guard tests now have 19 cases (11 from the spec).

## Review findings

Reviewed 2026-10-11 by a fresh agent (`/review build`). Input: mode and change folder only; there
was no other text in the arguments to ignore. Encrypted files were not read or shown; Story 2 was
checked only with true/false evaluations.

What holds (checked): `nix flake check` passes (run). `leak-guard-test` passes on `--rebuild`
(run). The integration claim is true: in a clone of the repository with this diff, a plain file
with a fake hash added with `git add -N` makes the `leak-guard` check fail with
`modules/system/leaky.nix:2  password hash` and no value; after removal it passes (run). Story 2:
on `nimbus`, `bea` and `truce`, `initialHashedPassword` of the operator and of `root` is set and
equal across the three hosts, and `hashedPassword`, `password`, `hashedPasswordFile` and
`initialPassword` are null (run: `nix eval` printing only booleans). The guard follows the
`desktop-reset` pattern (`writeShellApplication`, so shellcheck runs) and sits next to `lint` as
the spec decided. No reference to `security-check` is left outside `docs/changes/` (search:
`grep -rn security-check`). `AGENTS.md` keeps all its guardrails (read the diff). The install
images import only `modules/shared/secrets.nix` and nothing references the flake source, so the
claim "an image holds private values, never secrets" is true (search: `self`, `outPath`, `./.` in
`flake.nix`, `live-image/`, `modules/`). The mutation-style cases in `leak-guard-test.sh` can fail:
each pattern, the allow mark, the binary skip, the slash/no-slash paths and the "no value shown"
check have their own assertion (trace).

**R1 – The guard skips more files than git-crypt encrypts (fails open).** `is_encrypted` matches
a pattern with a slash as a bash glob, where `*` also matches `/`; git does not. It also ignores
`!filter` / `-filter` lines and `.gitattributes` files in subfolders. Reproduced with the built
guard and `git check-attr`: with `hosts/*.nix filter=git-crypt`, git leaves
`hosts/x/plain.nix` plain, but the guard skips it (exit 0 with a hash inside); with
`secrets.nix filter=git-crypt` plus `docs/secrets.nix !filter`, git leaves `docs/secrets.nix`
plain, the guard skips it. No live hole today: the four patterns in `.gitattributes` have no slash
and there are no negations (read). Test 5 has no wildcard, so it cannot see this. Suggestion:
fail closed – make the guard stop with an error on a `.gitattributes` line it does not fully
support (a wildcard together with a slash, `!`/`-` attributes, a nested `.gitattributes`), and add
a test for it; or note the limit in `secrets.md`.

Fixed 2026-10-11: the guard stops with an error on these rules (fail closed); git-crypt's own `.git-crypt/.gitattributes` (filter off for its folder) is supported and its folder is checked in full. Tests: wildcard with slash, filter off, nested rule, nested filter-off folder.

**R2 – Common password hash formats are not caught.** `$apr1$` (htpasswd, for example nginx basic
auth) and PHC hashes such as `$argon2id$` pass the guard (run: fixture file, exit lists only the
sha512-crypt-with-rounds and `$sha1$` lines; the last only by accident, it contains a `$1$` part). These have a
clear prefix, so the documented limit ("a secret without a clear pattern is not found") does not
describe them, and an operator who reads `secrets.md` will expect them to be caught. Suggestion:
add `apr1` and `argon2(id|i|d)` (perhaps `pbkdf2-…`, `scrypt`) to the pattern with a test each, or
name the formats that are caught in `secrets.md` as the full list.

Fixed 2026-10-11: `apr1` and `argon2(id|i|d)` added to the pattern, with a test; `secrets.md` lists the caught prefixes as the full set. `pbkdf2` and `scrypt` not added: not used in this repository; the list makes the limit visible.

**R3 – False alarm on shell positional parameters (note).** A plain shell line that echoes positional parameter 1 directly followed by positional parameter 2 (no space) is reported
as `password hash` (run). The allow mark is the documented way out, so this is within the spec;
noted because shell snippets in `.nix` files and scripts are common in this repository. Consider
requiring at least one more `$`-separated field for the short prefixes, with a test.

Not fixed 2026-10-11: within the spec (allow mark); agreed with the operator. Now named in `secrets.md` as a known false alarm.

**R4 – Step 3 and integration results are ticked, not recorded.** `Progress` ticks all steps, but
`technical.md` does not record the store-path comparison before and after the edit, the
`grep -c` result by the operator, or the run of the integration check. Not checked by me: the
store paths before the edit (no before state is available). The evaluation above shows the
outcome the store-path test was meant to prove. Test 8 (public key) cannot fail with the current
patterns; it is a guard against a future broader pattern, which is fine, but it does not prove
that public keys are "skipped" – nothing in the guard handles them.

Fixed 2026-10-11: results recorded under Progress. Test 8 kept as a guard for future broader patterns; `secrets.md` no longer says the guard skips public keys (see A7).

**R5 – Living documents still call the password hash a private value (for `/close`).**
`docs/architecture.md`, Layers table: `modules/system/secrets.nix` is described as "Private
values (encrypted with git-crypt)", but it holds the one secret exception. "Known technical debt"
still says "keeping only real secrets, such as password hashes, encrypted", which the new rule
contradicts (secrets are never in the repository); spec review round 2 already asked `/close` to
remove that entry. The diff changed the neighbouring pattern line but left both (read
`docs/architecture.md`).

Not fixed 2026-10-11: for `/close`, which updates `docs/architecture.md`.

Verdict: no blocker. R1 and R2 are holes in the safety net that the rule itself does not depend
on; fix or document them before Close. R3–R5 are notes.

### Acceptance review

Reviewed 2026-10-11 by a fresh agent (`/review accept`). Input: mode and change folder only; no
other text in the arguments to ignore. Encrypted files were not read or shown; Story 2 was checked
with evaluations that print only true/false and file names. My view was formed from
`functional.md`, `idea.md`, the diff and runs, before reading Deviations and the build review.

**A1 – Story 1, the rule: faithful.** `docs/product/secrets.md` has the four classes, each with a
meaning, examples and a place; the reason "whole repository in the Nix store, decrypted, used or
not" (N9); the password exception; the temporary gap in core value 3; public values in encrypted
files; install images (private yes, secrets never, not published); the stricter-class and
no-clear-class rules; identity limited to private keys and accounts, public SSH keys private.
Every row of the Context table has a class. `SECURITY.md` is only a pointer and the steps after a
leak; `AGENTS.md` adds one pointer and keeps every guardrail; `docs/architecture.md` points to the
document. (Read the diff and `secrets.md` against each criterion.)

**A2 – WireGuard row says more than is true: neutral drift.** The secret class says "a file made
by hand on the host, with the step written down", and the "Where each value is now" table puts the
WireGuard key there without a remark. The step is not written down: `docs/architecture.md` (Known
technical debt) still says "WireGuard key is a manual, unwritten step", and backlog item 4 holds
it. An operator who reinstalls `nimbus` and trusts the table will look for a step that does not
exist. Suggestion: one remark in the row ("step not yet written: backlog item 4 / host secret
change"). (Read `secrets.md`, `architecture.md`, `backlog.md`.)

Fixed 2026-10-11: the WireGuard row says the step is not written down yet (host secret change).

**A3 – Story 2, one place for the password: faithful.** On `nimbus`, `bea` and `truce`, only
`modules/system/secrets.nix` defines a password for the operator and `root`
(`options.users.users.definitionsWithLocations`, file names only); the values are set and equal
across hosts and for `root` and the operator; `hashedPassword`, `password`, `hashedPasswordFile`
and `initialPassword` are null; the three systems evaluate and dry-run build (run). "The same
password as now" I could not check myself: there is no before state I may read. The build review's
R4 (store-path comparison not recorded) stands.

**A4 – Story 3, the guard misses common password hashes: concerning deviation (small, fix in
Implement).** The intent is "a secret cannot reach the public repository by a mistake in a file
name", and the spec's own limit is "the guard catches only clear patterns (password hashes, private
key blocks)". `$apr1$` and `$argon2id$` hashes have clear prefixes and are not caught (build review
R2, run there); `secrets.md` says "a crypt hash, for example one that starts with …", which reads
as "all crypt hashes". This does not change the spec; add the formats with a test each, or list the
caught formats as complete in `secrets.md`, before `/close`.

Fixed 2026-10-11: see R2.

**A5 – Story 3, the rest: faithful.** The check runs in `just verify` through `nix flake check`
(`justfile`: verify → check). It passes on the repository and both checks build (run). On planted
files in a scratch folder with the real `.gitattributes`, it names file, line and kind, never the
value, and skips `vars.nix` (run). `scripts/security-check.sh` is gone, with no reference left
outside `docs/changes/` (search: `grep -rn security-check`). The allow mark is documented. The
fail-open glob handling (R1) has no effect on today's `.gitattributes` (four patterns without a
slash, read): neutral for the intent now.

**A6 – Age secret keys also caught: faithful adaptation.** A stricter reading, agreed with the
operator and written under Deviations.

**A7 – "It skips … public keys" in `secrets.md`: neutral drift.** Nothing in the guard skips public
keys; they are simply not matched (R4). True in effect, but a future broader pattern would make it
false without a code change that shows it. Suggestion: "public keys do not match its patterns".

Fixed 2026-10-11: "Public keys do not match its patterns."

**A8 – False alarm on positional parameters 1 and 2 without a space in shell lines: neutral drift.** Reproduced (run: a plain `echo`
line with positional parameters 1 and 2 → `password hash`). Within the spec, thanks to the allow
mark; see R3.

Not fixed 2026-10-11: see R3. The example in this finding was reworded in words, because the guard flagged it.

**A9 – Living documents for `/close`.** `docs/architecture.md` still calls
`modules/system/secrets.nix` "Private values" and keeps the debt entry "keeping only real secrets,
such as password hashes, encrypted", which the new rule contradicts (R5). The debt entry on the
username is answered by this change (username public) and can go.

Not fixed 2026-10-11: for `/close` (with R5).

Verdict: **accepted with notes.** What was built is what was meant. Fix A4 (or document the list
of caught formats as complete) before `/close`; A2 and A7 are one-line document fixes; A8 and A9
are notes for `/close`.

### Build review, round 2 (the guard after the R1/R2 fixes)

Reviewed 2026-10-11 by a fresh agent (`/review build`). Input: mode and change folder only; there
was no other text in the arguments to ignore. Encrypted files were not read, diffed or shown;
Story 2 was not checked again (round 1 and A3 cover it).

What holds (checked): `nix flake check` passes, and `leak-guard` and `leak-guard-test` pass on
`--rebuild` (run). The test file has 16 cases, as Deviations says (read). The four new tests can
fail: each unsupported rule has its own exit code and message assertion, and `nested-filter-off`
fails if the filter-off folder were skipped, because the root pattern `secrets.nix` would then hide
`.git-crypt/secrets.nix` (trace). The real `.git-crypt/.gitattributes` is accepted, and on a scratch
copy of the tracked plain files with the real `.gitattributes`, the built guard passes clean, then
reports a planted hash in `modules/system/leaky.nix` and in `.git-crypt/leak.txt` and skips one in
`hosts/x/vars.nix`, with no value shown (run). The prefix list in `secrets.md` is exactly the set
the regex matches (trace). No reference to `security-check` is left outside `docs/changes/`
(search: `grep -rn security-check`).

**R6 – A rule that sets the filter to something else is not seen (fails open; twin of R1).** The
fix stops on `!filter` and `-filter`, but not on a later rule that gives a git-crypt file another
filter value. Reproduced with the built guard and `git check-attr`: with
`secrets.nix filter=git-crypt` and then `docs/secrets.nix filter=lfs`, git does not encrypt
`docs/secrets.nix` (filter: lfs), but the guard skips it (exit 0 with a hash inside). The same with
a bare `docs/secrets.nix filter` (filter: set). `secrets.md` says the guard stops on "a rule that it
cannot follow exactly", which these rules are. No live hole today (the root file has four plain
`filter=git-crypt` lines, read). Suggestion: stop on every line that names `filter` in any form
other than `filter=git-crypt`, root and nested, with a test; or narrow the sentence in `secrets.md`.

Fixed 2026-10-11: every top-level rule that names `filter` with a value other than `filter=git-crypt` stops the guard ("other filter"); test with `filter=lfs` and a bare `filter`. `secrets.md` updated.

**R7 – A macro line is read as a file pattern (note).** With `[attr]crypt filter=git-crypt` and
`secrets.nix crypt`, git encrypts `secrets.nix`; the guard takes `[attr]crypt` as a glob, so it
reports the encrypted `secrets.nix` (false alarm, fails closed) and skips a plain file named
`tcrypt` (fails open) (run). Unlikely in this repository. Suggestion: stop on an `[attr]` line,
with the same check as R6.

Fixed 2026-10-11: a macro line stops the guard ("macro") and is no longer read as a pattern; one test.

**R8 – A read error hides a file (note).** In the scan, `grep … | grep -v … | cut … || true`
turns a grep error (exit 2, for example an unreadable file) into "no hits", and an error of `find`
inside the process substitution does not stop the script (trace; not run). Inside the Nix build
every file is readable, so no effect now. Suggestion, if touched again: treat grep exit 2 as a
failure.

Fixed 2026-10-11: a `grep` error (exit code above 1) stops the guard with "cannot read <path>"; one test (a file without read permission). The same change fixed an empty-result fault that the tests found at once.

Still open from round 1: R5 (for `/close`).

Verdict: no blocker. R6 is the same kind of hole as R1 and should be fixed or documented before
Close; R7 and R8 are notes.
