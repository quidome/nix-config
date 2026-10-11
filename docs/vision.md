# Product vision: nix-config

## The user's problem space
The user is the operator: one person who owns, maintains and uses a small set of personal
machines. Nobody else maintains them. The operator wants each machine to be the same, known
setup every time, without hand work after a reinstall, and wants to try new things on the
desktop without losing a working machine.

Hosts now:
- `nimbus` – main laptop; most daily work, including work with Claude, happens here.
- `bea` – desktop; the most powerful machine, but in another room, so used less.
- `truce` – old laptop, used for tests.

## What this product is
One repository that describes each personal NixOS machine completely: system and user
configuration together, plus live images to install a new machine. A host chooses what it is
(graphical session, kind of machine, software groups); shared modules decide how.

What it is not:
- Not a setup for more people. Accounts for family members are out of scope.
- Not a store for identity. Keys (SSH, GPG), password manager, browser sign-in and device
  pairing (Syncthing) are set up by hand after a rebuild. This is a choice: the configuration
  describes the machine, not who the operator is.

## Core values
1. **Secrets never leak.** Not in git, not in the Nix store, not in logs. This is the worst
   possible failure. One known exception: the temporary initial password hash may be in the
   Nix store, because the operator changes the password right after install.
2. **Data on disk is never lost** because of a configuration change.
3. **Any host can be rebuilt in minutes**, and after the rebuild it is ready to use, except for
   the identity steps above.
4. **The daily desktop always works.** Plasma works on every graphical host, after every change.

## Where we are
The setup works well and nothing is hard. Three hosts are configured. Hosts choose a graphical
session, a kind of machine and software groups; shared modules do the rest. Plasma is the
daily desktop; niri is available as a second, minimal session. Known gap: host secrets (for
example the WireGuard key) are files made by hand on the host, so a rebuild of such a host needs
one step more than the identity steps. Every value has a written class, and a leak guard in the
checks stops a password hash or private key in a plain file. The structure is decent and
could be cleaner in places.

## North star
Every personal machine comes back from one command and a few minutes of waiting, the same as
before, and the operator only has to sign in.

## Where we are going
Keep what works. Make the structure cleaner where that makes changes easier, not for its own
sake. Add new tools when they are needed.

## Longer horizon
No large changes are planned.

## User journeys
- **Replace or reinstall a machine.** The operator boots the live image, installs the host from
  the repository, rebuilds, and then does only the identity steps by hand.
- **Daily change.** The operator changes a module or a host, checks and builds it, and switches.
  If something is wrong, the operator rolls back to the previous generation.
- **Try something new.** The operator switches a host to niri or adds a new tool, uses it for a
  while, and goes back to plasma without losing anything. The work on niri stays in the
  repository for the next time.

## Priorities
1. Secrets stay private – a leak cannot be undone.
2. No data loss – data on disk cannot be rebuilt from the repository.
3. Fast rebuild to a ready host – this is what the operator values most in daily use.
4. Plasma always works – it is the daily desktop.
5. Small hosts and clear shared modules – this keeps 3 and 4 easy to maintain.

## Principles
- A host chooses, and adds only what is unique to it (hardware, software that only that host
  uses). Everything shared lives in modules.
- Plasma is the daily desktop and must always work. niri is the playground: it must build, but
  it may be rough. A broken detail in niri never blocks a change.
- Do not remove a working experiment only because it is not in use now; keeping it costs less
  than building it again.
- Identity is set up by hand, on purpose.
- Every value has a class – secret, private, public or identity – and the class decides where it
  lives (`docs/product/secrets.md`). Private values stay hidden, even in a public repository.

## Open questions
- None at the moment.

## Change log
| Date | Change |
|------|--------|
| 2026-10-11 | Vision created |
| 2026-10-11 | Exception for the temporary password hash in the Nix store; principle that every value has a class (secret management change) |
| 2026-10-11 | Four value classes; known gap for host secrets in "where we are" (spec review round 2) |
| 2026-10-11 | Where we are: written value classes and leak guard (secret management change closed) |
