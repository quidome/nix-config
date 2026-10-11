# Idea: Secret management

**Status**: ready for discovery
**Vision fit**: protects core value 1 and priority 1 (secrets never leak – not in git, not in the
Nix store, not in logs) in a public repository, and core value 3 (a host is ready to use minutes
after a rebuild).
**Date**: 2026-10-11

## The problem
The repository is public. Secrets are handled in two ways now:
- git-crypt encrypts whole files, chosen by file name (`.gitattributes`). A secret in a file with
  another name goes into git as plain text. One key opens all encrypted files.
- Some host secrets are files made by hand on the host, for example the WireGuard key on
  `nimbus`. After a reinstall the VPN does not work until the operator makes the file again; if
  the key is lost, the VPN server must change too.

There is no written rule for what is a secret. Some values are encrypted only to keep them
private, not because they are secret: the username is encrypted with the user account, but it is
already in plain text in other files.

## The idea
Three decisions, in this order:
1. **What is a secret?** A rule that says which values must be encrypted, which may be public,
   and which stay hand work.
2. **Where are secrets stored?** In the repository (encrypted), only on the host, or in a separate
   store (for example Bitwarden or gopass).
3. **Which tool?** git-crypt (now), sops-nix, agenix, or another tool. This is for `/design`.

## Why now
The WireGuard item in the backlog cannot be done without this decision, and the user account
question (plain or hidden) is the same question. Every new host secret adds to the problem.

## How it fits
- Core value 1 and priority 1: the strongest rule of the product. Also "not in the Nix store":
  files in the store can be read by every user on the host.
- Core value 3: a new host must get its secrets with as little hand work as possible.
- Principle "identity is set up by hand, on purpose": the operator's personal keys and accounts
  (SSH and GPG keys, Bitwarden, browser sign-in, device pairing) stay out of scope, unless
  Discover finds a reason to change this. Then it is a question for `/vision`.
- Relation to other items: `/persist` (backlog) may become the place for host keys; decision 0001
  is not affected.

## User view
The operator is the only user. Moments that matter:
- **Add a secret**: the operator adds a new secret (for example a VPN key) and must know where it
  goes and that it cannot leak.
- **New or reinstalled host**: the host must get its secrets with at most one short, written step.
- **Daily work**: editing configuration must not need the secret key for files that are not
  secret; a check must catch a secret in a plain file before it reaches git.
- **Key loss**: the operator must know how to recover when a host key or the main key is lost.

Known from the tools (for `/design`): sops-nix and agenix let each host decrypt with its own key
(usually its SSH host key), so each new host must first be added as a recipient. git-crypt needs
the one repository key on each machine that builds.

## Open questions
- Which kinds of values are in the encrypted files now (kinds only, not content)?
- Which values are secret, which are only private, which may be public? Is the username public?
- Is one step per new host acceptable, or must it be zero?
- Where does the main key (or the keys) live, and how is it backed up?
- Must the live install images keep working with the same secrets (authorized keys)?
- How does the operator recover after loss of a host key, or of the main key?
- Is a check wanted that stops a commit with a secret in a plain file?
- Must the change be done for all hosts at once, or one host first?
