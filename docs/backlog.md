# Backlog

Open work, most important first, one line each.
Background for each item: "Known technical debt" in `architecture.md`.

1. host secrets: write down how the WireGuard key on `nimbus` is set up (or let the configuration provide it); choose a tool for host secrets (git-crypt, sops-nix, agenix), see decision 0002
2. check: Ghostty starts and is not slow on `truce`, when `truce` runs this configuration (else try kitty)
3. check: Ghostty in a real niri session (Mod+Enter, network click, light/dark); then remove the Alacritty colours (technical debt in `architecture.md`)
