# Functional spec: Secret management

**Status**: approved
**Change**: docs/changes/2026-10-11-secret-management/
**Date**: 2026-10-11

## Context
This repository describes the operator's personal hosts and is **public** on GitHub. The vision's
first core value is "secrets never leak – not in git, not in the Nix store, not in logs".

Today git-crypt encrypts whole files, chosen by file name (`.gitattributes`: `secrets.nix`,
`vars.nix`, `home-vars.nix`, `system-vars.nix`). There is no written rule for what must be
encrypted. Two older documents exist: `SECURITY.md` (public, out of date: it still lists
`hardware-configuration.nix` as protected and says `vars.nix` holds passwords) and
`scripts/security-check.sh` (fails when any file with a protected name is staged, although
git-crypt encrypts those files on commit; nothing runs it). A check of the encrypted files (structure only, values masked) showed:

| Value | Where now | Kind |
|---|---|---|
| Initial password hash for the operator and `root` | `modules/system/secrets.nix` (`initialHashedPassword` for both users), and a second copy in `hosts/truce/vars.nix` (also `initialHashedPassword`, for the operator) | secret – a temporary first-login password; the operator changes it with `passwd` right after install, before the first graphical login |
| git and jujutsu name and email address | `hosts/*/home-vars.nix` | private |
| Host names in the SSH client settings | `hosts/*/home-vars.nix` | private |
| User account (name, groups, shell), `networking.hostId` | `hosts/*/vars.nix` | public (the username is already plain text in `flake.nix`) |
| Authorized SSH public keys (for login and for disk unlock at boot) | `modules/shared/secrets.nix`, used by `hosts/*/vars.nix` and the install images | private: public keys, but their comments can name users and hosts |

The WireGuard private key on `nimbus` is a file made by hand on the host. It is a real host
secret, but it is **not part of this change**: it comes with a later change, which also chooses
a tool for host secrets (git-crypt, sops-nix, agenix or another).

The operator decided (2026-10-11):
- Private values stay hidden; making them public feels uneasy.
- git-crypt stays for now.
- The generated hardware configuration is public (already done as a separate fix).
- The username is public.
- The temporary initial password hash may be in the Nix store, as a written exception in the
  vision (it is changed at once after install). Recorded in the vision by `/vision`.
- The leak guard runs in `just verify` only, not as a git pre-commit hook.
- The rule lives in `docs/product/secrets.md`.

This change gives the operator a written rule, removes the double password hash, and adds a
guard against a secret in a plain file.

## User stories

### Story 1: A rule for every value
**As the** operator, **I want to** have one written rule that puts each value in this
repository in a class and says where that class lives, **so that** I know what to do with a new
value without having to think about it, and nothing leaks by mistake.

#### Acceptance criteria
- [ ] `docs/product/secrets.md` describes the classes, each with a definition, examples from this
  repository, and where values of that class live:
  - **secret** – a value that gives access when known (password hash, private key, token).
    Never in the repository: when a host is built from the unlocked checkout, the whole
    repository is copied into the Nix store, decrypted, whether a file is used or not. Until the host secret change, a secret is a file
    made by hand on the host, with the step written down. One exception: the temporary initial
    password hash is a value in an encrypted file.
  - **private** – a value that is not secret but that the operator does not want public (email
    address, host names, network names). Encrypted in the repository; may be in the Nix store,
    which stays on the host.
  - **public** – everything else (configuration, generated hardware configuration). Plain text.
  - **identity** – the operator's personal private keys and accounts (private SSH and GPG keys,
    password manager, browser sign-in, device pairing). Not in the repository; set up by hand
    (vision principle). The operator's public SSH keys are not identity: they are private values
    in the repository.
- [ ] The document says where a future **host secret** (a secret that belongs to a host, such as
  the WireGuard key) goes until the host secret change: a file made by hand on the host, with
  the step written down. The document calls this a known, temporary gap in core value 3 (only
  identity steps after a rebuild), to be closed by the host secret change.
- [ ] The document says that the whole repository ends up in the Nix store of every machine that
  builds it, and what that means for each class.
- [ ] Each value in the table under Context has a class in the document.
- [ ] The document states the exception: the temporary initial password hash may be in the Nix
  store.
- [ ] The document says that public values may stay in an encrypted file when they share it with
  private values.
- [ ] The document says that an install image may hold private values but never secrets, and
  that an image is not published.
- [ ] `AGENTS.md`, `docs/architecture.md` and `SECURITY.md` point to the document instead of
  repeating the rule. `SECURITY.md` keeps only a short pointer and what to do after a leak.
  `AGENTS.md` keeps its own guardrails for agents (never read or show encrypted files).

#### Behaviour
The operator wants to add a value. They look up its class in the document and put it in the
place the document names. For a private value, that is a file that git-crypt encrypts; for a
secret, a file made by hand on the host.

#### Errors and edge cases
- A value fits two classes (for example a public key that also reveals a host name): the stricter
  class wins.
- A value has no clear class: the document says to treat it as private and to ask `/vision` to
  extend the rule.

### Story 2: One place for the initial password
**As the** operator, **I want** the initial password hash to be defined in one place for all
hosts, **so that** a change of the temporary password is one edit and cannot break a host build.

#### Acceptance criteria
- [ ] The initial password hash is defined in exactly one encrypted file.
- [ ] `truce` no longer has its own copy.
- [ ] On every host, the operator and `root` get the same initial password as now; a fresh
  install still allows the first login with it.
- [ ] Builds of `nimbus`, `bea` and `truce` pass.

#### Behaviour
No visible change. After an install, the operator logs in with the temporary password and
changes it with `passwd`, as now.

#### Errors and edge cases
- Existing hosts: the initial password is used only when a user is created, so a running host
  is not affected.
- If the hash is removed by mistake, a fresh install has users without a password. The operator
  can still log in over SSH with their key.

### Story 3: Leak guard
**As the** operator, **I want** a check that fails when a secret is in a file that git does not
encrypt, **so that** a secret cannot reach the public repository by a mistake in a file name.

#### Acceptance criteria
- [ ] The check fails when a plain (not encrypted) tracked or staged file contains a password
  hash or a private key block; the message names the file and the line number, but not the
  value.
- [ ] The check passes on the current repository.
- [ ] The check ignores files that git-crypt encrypts (they are plain on the operator's disk).
- [ ] The check does not fail on public keys.
- [ ] The check runs as part of the normal project checks (`just verify`).
- [ ] `scripts/security-check.sh` is removed; the leak guard replaces it.

#### Behaviour
The operator runs `just verify`. With no secret in a plain
file, nothing changes. With one, the check stops and names the file and line.

#### Errors and edge cases
- A false alarm (a value that looks like a secret but is not): the operator can mark that one
  line as allowed in a documented way; the mark is visible in review.
- A secret that does not match any known pattern is not caught. The rule in Story 1 stays the
  main protection; the guard is a safety net.

## Interface
- New living document `docs/product/secrets.md` with the rule.
- `just verify` (and `nix flake check`, which it runs) includes the leak guard.
- Example of a failing check (value not shown):
  ```
  leak guard: possible secret in a plain file
    modules/system/example.nix:12  password hash
  ```

## Consistency
- Uses git-crypt as now; no change in how the operator unlocks the repository.
- The guard follows the existing checks (alejandra, statix, deadnix in `nix flake check`).
- The rule repeats the vision principle that identity is hand work.

## What changes for existing users
No breaking changes. Running hosts keep their passwords. A new check may fail if a plain file
contains a value that looks like a secret.

## Warnings from architect and engineer
- **The password hash is in the Nix store**: NixOS writes user settings into the store, where
  every user on the host can read them. git-crypt does not change this. Accepted as a written
  exception in the vision; the host secret change may remove it later.
- **The guard does not run on commit.** A commit made without `just verify` is not checked.
- **Git history keeps old versions.** Encrypted files stay decryptable with the git-crypt key
  forever; values that were ever plain stay public. This change does not repair history.
- **One key opens everything.** Every machine that builds needs the full git-crypt key; this
  change keeps that.
- **Pattern limits.** A WireGuard private key looks like any other base64 key, also like the
  public keys in the repository, so a pattern cannot tell them apart. The guard catches only
  clear patterns (password hashes, private key blocks).
- **Encrypted files inside the check.** `nix flake check` sees a copy of the source, not git,
  so the guard must find the encrypted files from `.gitattributes`, not from `git-crypt`.
- **Which password option.** Both copies set `initialHashedPassword` (seen in the structure of
  the files, values masked). Design checks again before removing the copy.
- **Duplicate definitions** of the same option in two files make a build fail when they differ;
  removing the copy must keep the value the same.

## Not in scope
- The WireGuard key and the choice of a tool for host secrets (later change).
- Rotation of the WireGuard key or the password.
- Root SSH login (separate idea in `docs/ideas.md`).
- Making private values public.
- The commented-out accounts for more users in `hosts/truce/vars.nix`.
- Cleaning git history.
- Moving public values out of encrypted files.
- A git pre-commit hook for the leak guard.
- Recovery after loss of the git-crypt key or a host key (key loss goes with the host secret
  change; a backup of the git-crypt key is a line in `docs/ideas.md`).
- Daily work on a machine without the git-crypt key.

## Open questions
- None. The words "secret", "private", "public", "identity" and "host secret" are added to
  `docs/language.md` by `/vision` together with the password exception.

## Spec review
<Filled in by `/review spec` (a fresh agent). One row per user story. Design does not start
without this table. A "does not serve" row sends the spec back to Discover.>

### Round 1

Fixed in the spec on 2026-10-11, with the operator: N1 (secret class: never a value in the
configuration), N2 (`SECURITY.md` and `scripts/security-check.sh` in Stories 1 and 3), N3
(authorized keys are private), N4 (install images), N5 and N6 (warnings for Design).

| Story | What the user is doing here | Verdict | Note |
|---|---|---|---|
| 1. A rule for every value | Adding a new value (token, key, address) and deciding where it goes, without leaking it | serves – note | N1, N2, N3, N4 |
| 2. One place for the initial password | Installing a host and logging in the first time; changing the temporary password | serves – note | N5 |
| 3. Leak guard | Daily change: checking before a commit that no secret slipped into a plain file | serves – note | N2, N6 |

Reviewed 2026-10-11 by a fresh agent (`/review spec`). Encrypted files were not read.

**N1 – The secret class leaves out "never in the Nix store".** Vision core value 1 and the
`secret` entry in `docs/language.md` both say "never in the Nix store (one exception)". The
Story 1 criterion only says "Encrypted in the repository, or not in the repository at all".
With git-crypt, every value in an encrypted `.nix` file that the configuration uses is written
into the Nix store. So in practice "encrypted in the repository" is safe only for the password
hash exception; for any other secret the only place that keeps the vision is "not in the
repository" (a file made by hand on the host, as for the WireGuard key). If the document repeats
the criterion as written, the operator will put the next token in `secrets.nix` and it lands in
the store – the failure the rule is meant to stop. Add "never in the Nix store" to the class and
say what that means with git-crypt. (Checked: read `vision.md`, `language.md`, this spec.)

**N2 – An older rule and an older check already exist and are not mentioned.** `SECURITY.md`
(public, at the repository root) lists the protected files, including
`hardware-configuration.nix`, which is now plain, and says `secrets.nix` holds "API keys,
passwords, certificates" and `vars.nix` holds "passwords". It tells the reader to run
`scripts/security-check.sh`, which also treats `hardware-configuration.nix` as protected and
fails when any `vars.nix`/`secrets.nix` is staged – that is, on every normal commit of an
encrypted file. Neither file is in the spec. After this change the operator would have two rules
that disagree and two "security checks" that do different things. Story 1 should name
`SECURITY.md` next to `AGENTS.md` and `docs/architecture.md`; Story 3 should say what happens to
`scripts/security-check.sh` (replaced by the guard, or removed). (Checked: search
`grep -rln "git-crypt\|secret"` outside `docs/`, then read both files.)

**N3 – The stricter-class edge case may contradict the Context table.** The table classes
"authorized SSH public keys" and "SSH public keys for disk unlock" as public. SSH public keys
usually carry a comment such as `user@hostname`; by the edge-case rule ("the stricter class
wins") such a key is private. Both answers lead to the same place today (the keys stay in
encrypted files), but the document should class them consistently. (Not checked: the keys are
in encrypted files.)

**N4 – The live images are not a host.** The private class says it "may be in the Nix store,
which stays on the host". `baseIso` and `bcachefsIso` import `modules/shared/secrets.nix`, so its
values go into an image file that can be copied to a USB stick or shared. The document should
say whether private values in an install image are fine. (Checked: read `flake.nix`.)

**N5 – "A running host is not affected" depends on which option truce's copy uses.** The edge
case holds if both copies set an initial password (used only when the user is created). If
`truce`'s copy sets the enforced password option instead, removing it changes behaviour on the
running `truce`. Design should check this before removal. No plain file sets
`mutableUsers` or a password option. (Checked: search
`grep -rn "mutableUsers\|hashedPassword\|initialPassword"` in plain files – no hits; the encrypted
files were not read.)

**N6 – Where the guard runs.** It serves the daily-change journey: the commit workflow in
`AGENTS.md` runs `just check`, so the guard runs there too if it is part of `nix flake check`,
as the Interface says. Note for Design: inside `nix flake check` the guard sees the source copy,
not git, so "tracked or staged" and "files that git-crypt encrypts" must be decided from the
file list and `.gitattributes`, not from `git-crypt status`. (Checked: read `flake.nix`
`checks.lint` and `justfile`.)

### Round 2

| Story | What the user is doing here | Verdict | Note |
|---|---|---|---|
| 1. A rule for every value | Adding a new value (token, key, address) and deciding where it goes, without leaking it | serves – note | N7, N8, N9, N10 |
| 2. One place for the initial password | Installing a host and logging in the first time; changing the temporary password | serves | – |
| 3. Leak guard | Daily change: checking before a commit that no secret slipped into a plain file | serves | – |

Reviewed 2026-10-11 by a fresh agent (`/review spec`). Encrypted files were not read. N1-N6 from
round 1 are fixed in the spec text (checked: read Stories 1-3 and the warnings).

**N7 – The word list and the vision still say the round 1 version.** `docs/language.md`
`secret`: "Encrypted, or not in the repository"; the spec now says "never a value in the
configuration" and, until the host secret change, a file made by hand on the host. `host secret`:
"the configuration may provide it"; the spec says that for now it does not. The vision principle
names three classes ("secret, private or public"); the spec has four (also identity). Only
`/vision` changes these words, so if they stay, the living documents tell the operator that an
encrypted file is a place for a secret – the mistake N1 fixed. Ask `/vision` to align them.
(Checked: read `language.md`, `vision.md`, `git diff` of both.)

**N8 – A hand-made host secret is a step core value 3 does not allow.** Core value 3 and the north
star: after a rebuild only the identity steps remain. The language says a host secret is "not
identity". So every new host secret under this rule adds a non-identity hand step to the reinstall
journey. That is a fair interim (only the WireGuard key is affected now, and it is out of scope),
but it is a gap in the vision, not a design detail. The rule document should call it a known,
temporary gap and point to the host secret change, so the operator does not read it as the
lasting answer. (Checked: read `vision.md` core values and journeys, `language.md`.)

**N9 – The reason in the secret class is too narrow.** It says a value goes into the Nix store
when the configuration *uses* it. With a flake in a git checkout, the build copies the whole
source tree – including the git-crypt files, plain because the checkout is unlocked – into the
store, used or not. So "an encrypted file that the configuration does not use" is also not a
safe place. The outcome of the rule (a file by hand on the host) is right; the stated reason
should be "every file in the repository" so the operator and the host secret change do not
rely on "unused is safe". (Trace: `flake.nix` is a git flake; Nix copies tracked files from the
working tree. Not run: checking the store copy would mean reading an encrypted file.)

**N10 – Two edges of the identity class.** (a) Identity includes "SSH keys" and is "never in the
repository", but the authorized SSH public keys are in the repository, classed private. The
document should say that identity means the private keys and accounts, and that public keys
used for login are configuration – else the stricter-class rule could push them out of the
repository and break login on the install images. (b) `AGENTS.md` should point to the document
for the rule but keep its agent guardrails (never read encrypted files, `git-crypt status`
first); "instead of repeating the rule" must not remove them. (Checked: read `AGENTS.md`,
`language.md`, the Context table.)

**Not covered, not listed as out of scope.** `idea.md` names two user moments the spec drops
without a line in "Not in scope": key loss (how to recover after loss of the git-crypt key or a
host key) and daily work without the key for non-secret files. Both fit the later host secret
change; add them to "Not in scope" so they are not lost. Also, `docs/architecture.md` "Known
technical debt" still lists "the user account is hidden, but the username is not"; this change
answers it (username public, may stay in the encrypted file), so `/close` should remove that
entry. (Checked: read `idea.md`, `architecture.md`, `backlog.md`.)

Fixed in the spec on 2026-10-11, with the operator: N7 (`/vision` aligned `language.md` and the
vision), N8 (known gap in core value 3), N9 (whole repository in the Nix store), N10 (identity
means private keys only; `AGENTS.md` keeps its guardrails), and the two dropped moments under Not
in scope. No third round: the changes follow from the review. Spec approved by the operator.
