# 0002 – git-crypt until host secrets

**Status**: valid
**Date**: 2026-10-11
**Change**: Secret management (change documents in git history)

## Context
The repository is public. git-crypt encrypts whole files, chosen by file name in
`.gitattributes`. When a host is built from the unlocked checkout, the whole repository goes into
the Nix store, decrypted. So encryption in the repository keeps values out of git, not out of the
store. Today the only secret in the repository is the temporary initial password hash, and the
only host secret (the WireGuard key on `nimbus`) is a file made by hand on the host. The other
encrypted values are private, not secret.

## Decision
Keep git-crypt for private values and for the temporary initial password hash (a written
exception in goal 1 in `AGENTS.md`). Put no other secret in the repository: until the host secret change, a
secret is a file made by hand on the host, with the step written down. The host secret change
chooses the tool for host secrets. The rule is in `docs/product/secrets.md`.

## Options considered
| Option | For | Against |
|--------|-----|---------|
| git-crypt (keep) | Already in use; no migration; private values may be in the Nix store anyway | Secrets in an encrypted file still end up in the Nix store; one key opens every file in the whole history |
| sops-nix | Secrets decrypted at activation, outside the Nix store; per-host keys | New tool and key setup for one weak secret; private values still need a place |
| agenix | Same gain as sops-nix, simpler; uses SSH host keys | Same cost as sops-nix; host keys must exist before the first build |

## Consequences
- No migration now. The repository keeps one key for all encrypted files.
- A new secret cannot go into an encrypted file; it is hand work on the host until the host
  secret change. This is a known gap in goal 3 in `AGENTS.md`.
- The leak guard stops a password hash or private key in a plain file; it reads `.gitattributes`
  and must change with it.
- The host secret change must choose sops-nix, agenix or another tool, and decide if this record
  is replaced.
