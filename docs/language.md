# Language

The words that all documents, code and conversations about this product use. Only the Vision
stage adds, changes or removes words. Define meaning, not mechanics: no flags, paths or formats.

| Term | Meaning | Use / do not use |
|------|---------|------------------|
| operator | The one person who maintains and uses the machines | Say operator, not admin or user, in stories |
| host | One personal machine that this repository describes | Say host, not machine or system, in documents |
| rebuild | Make a host match the repository again, from an install or from a running system | |
| ready to use | A rebuilt host where only the identity steps remain | |
| identity steps | The hand work after a rebuild: keys, password manager, browser sign-in, device pairing | Never automated by this product, on purpose |
| graphical session | The desktop a host starts: none, plasma or niri | |
| daily desktop | Plasma: the graphical session that must always work | |
| playground | niri: a graphical session that must build but may be rough | |
| form factor | The kind of host: laptop, desktop or server | |
| role | An optional group of software that a host turns on | Say role, not profile; profiles are the always-on base |
| secret | A value that gives access when known: password hash, private key, token | Never in the repository, so never in the Nix store (one exception: the temporary initial password hash, in an encrypted file) |
| private | A value that is not secret, but that the operator does not want public: email address, host names, network names | Encrypted in the repository; may be in the Nix store |
| public | Every value that is not secret, private or identity | Plain text |
| host secret | A secret that belongs to a host, not to the operator, such as the WireGuard key | Not "identity"; for now a file made by hand on the host, with the step written down |
| identity | The operator's personal private keys and accounts: private SSH and GPG keys, password manager, browser sign-in, device pairing | Never in the repository; see identity steps. Public SSH keys are private values, not identity |
