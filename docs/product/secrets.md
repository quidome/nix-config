# Secrets and private values

What it does **now**, for the operator. Updated at each /close that changes it.

## Purpose
This repository is public on GitHub. Every value in it has a class – secret, private, public or
identity – and the class decides where the value lives. With this rule the operator knows where a
new value goes without having to think about it, and nothing leaks by mistake (vision core
value 1: secrets never leak).

## Behaviour

### Why the Nix store matters
When a host is built from the unlocked checkout, Nix copies the **whole repository** into the Nix
store, with the git-crypt files decrypted – whether the configuration uses a file or not. The Nix
store is readable by every user on the host. So an encrypted file is not a safe place for a
secret: only a value that is not in the repository at all stays out of the store.

### The four classes

| Class | Meaning | Examples in this repository | Where it lives |
|-------|---------|-----------------------------|----------------|
| **secret** | Gives access when known: password hash, private key, token | The temporary initial password hash (the one exception); the WireGuard private key on `nimbus` (a host secret) | Never in the repository. For now a file made by hand on the host, with the step written down. Exception: see below |
| **private** | Not secret, but the operator does not want it public: email address, host names, network names | git and jujutsu name and email address; host names in the SSH client settings; authorized SSH public keys | Encrypted with git-crypt. May be in the Nix store |
| **public** | Every value that is not secret, private or identity | All other configuration; the generated hardware configuration; the username; the user account (groups, shell); `networking.hostId` | Plain text. May stay in an encrypted file that it shares with private values |
| **identity** | The operator's personal private keys and accounts: private SSH and GPG keys, password manager, browser sign-in, device pairing | – (none, on purpose) | Never in the repository. Set up by hand after a rebuild (the identity steps) |

Public SSH keys are not identity. The authorized SSH public keys (for login and for disk unlock at
boot) are private values: their comments can name users and hosts.

### Where each value is now

| Value | File | Class |
|-------|------|-------|
| Initial password hash for the operator and `root` | `modules/system/secrets.nix` (encrypted) | secret – the exception |
| git and jujutsu name and email address | `hosts/*/home-vars.nix` (encrypted) | private |
| Host names in the SSH client settings | `hosts/*/home-vars.nix` (encrypted) | private |
| User account (name, groups, shell), `networking.hostId` | `hosts/*/vars.nix` (encrypted, shared with private values) | public |
| Authorized SSH public keys | `modules/shared/secrets.nix` (encrypted) | private |
| Generated hardware configuration | `hosts/*/hardware-configuration.nix` (plain) | public |
| WireGuard private key on `nimbus` | a file made by hand on the host, not in the repository | secret (host secret); the step is not written down yet (backlog: host secret change) |

### The one exception: the initial password hash
The temporary initial password hash for the operator and `root` is a value in one encrypted file,
`modules/system/secrets.nix`, and so it is in the Nix store. The operator changes the password
with `passwd` right after install, before the first graphical login. This exception is written in
the vision.

### Host secrets: a known, temporary gap
A host secret (a secret that belongs to a host, such as the WireGuard key) is for now a file made
by hand on the host, with the step written down. A rebuild of such a host therefore needs one step
more than the identity steps – a gap in vision core value 3. The host secret change closes it and
chooses the tool for host secrets.

### Install images
An install image may hold private values (it uses the authorized SSH public keys), never secrets.
An image is not published.

### Adding a value
1. Find its class in the table above.
2. Secret: do not put it in the repository; make a file by hand on the host and write down the
   step. Private: put it in a file that git-crypt encrypts (see `.gitattributes`). Public: plain
   text.
3. Run `just verify`.

## Errors and limits
- **A value fits two classes** (for example a public key whose comment names a host): the
  stricter class wins.
- **A value has no clear class**: treat it as private and ask `/vision` to extend the rule.
- **Git history keeps old versions.** Encrypted files stay readable with the git-crypt key
  forever; a value that was ever pushed as plain text stays public. See `SECURITY.md` for the steps
  after a leak.
- **One key opens everything.** Every machine that builds needs the full git-crypt key.

### Leak guard
The `leak-guard` check (part of `nix flake check`, so of `just check` and `just verify`) fails when
a plain file holds a line that looks like a secret:

- `password hash` – a hash that starts with one of these prefixes, and only these: `$1$`, `$2$`,
  `$2a$`, `$2b$`, `$2x$`, `$2y$`, `$5$`, `$6$`, `$7$`, `$y$`, `$gy$` (crypt), `$apr1$`
  (htpasswd), `$argon2id$`, `$argon2i$`, `$argon2d$`;
- `private key` – the header line of a private key block (OpenSSH, PEM or PGP);
- `age secret key` – an age secret key (it starts with `AGE-SECRET-KEY-1`).

It names the file, the line number and the kind, never the value. It skips files that
`.gitattributes` marks for git-crypt (inside the check there is no git, so it reads
`.gitattributes`) and binary files. Public keys do not match its patterns.

It stops with an error (and does not guess) when `.gitattributes` has a rule that it cannot
follow exactly: a wildcard in a pattern with a slash, any filter rule other than the git-crypt
filter (also one that turns it off), a macro (a named group of attributes), or a `.gitattributes`
in a subfolder that does more than turn the filter off for its whole folder
(as git-crypt's own `.git-crypt/.gitattributes` does; files in such a folder are all checked). It
also stops when it cannot read a file.

A false alarm: add the mark `leak-guard: allow` in a comment on that line. The mark is visible in
review. A known false alarm: script arguments 1 and 2 with no space between them look
like a short hash prefix.

Limits – the guard is a safety net; the rule above is the main protection:
- A secret without a clear pattern is not found. A bare base64 key, such as a WireGuard key, looks
  like a public key, so there is no pattern for it.
- It runs only with `just verify` (or `just check`), not on each commit.
- It checks only tracked and staged files (what Nix copies from the checkout).

## Interface
- Classes and places: this document. `docs/language.md` defines the words.
- Encrypted files: `.gitattributes` (`secrets.nix`, `vars.nix`, `home-vars.nix`,
  `system-vars.nix`).
- Check: `just verify`. Example of a failure:
  ```
  leak guard: possible secret in a plain file
    modules/system/example.nix:12  password hash
  ```
- Steps after a leak: `SECURITY.md`.
