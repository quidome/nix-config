# Security Policy

This repository describes personal hosts and is public. Values that must not be public are
encrypted with git-crypt; secrets are never in the repository (one written exception).

The rule – which value is secret, private, public or identity, and where it lives – is in
[`docs/product/secrets.md`](docs/product/secrets.md). `just verify` runs a leak guard that fails
on a secret in a plain file.

## After a leak

1. **Rotate the leaked secret** (password, key, token) at once. Removing it from the repository
   is not enough.
2. **A leak of the git-crypt key** exposes every encrypted file in the whole git history, not only
   the current files. Treat every value in those files as public, and rotate every secret that
   was ever in them.
3. **A value that was ever pushed as plain text stays public**, also after a fix or a history
   rewrite: copies may exist outside this repository.
