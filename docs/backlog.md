# Backlog

Open work, most important first. Changes link to their folder; small fixes are one line.
Background for each item: "Known technical debt" in `architecture.md`.

1. technical: remove the `server` form factor – `/vision` first (word list), then `/design`
2. check: does an encrypted file use `/persist`? Operator runs `grep -l persist` on the encrypted files; then remove it or give it a purpose
3. product doc: write down how the WireGuard key on `nimbus` is set up, in the workstations document in `docs/product/` (or let the configuration provide it) – parked: becomes the host secret change (tool choice: git-crypt, sops-nix, agenix), after [Secret management](changes/done/2026-10-11-secret-management/)
4. check: Ghostty starts and is not slow on `truce`, when `truce` runs this configuration (else back to Discover with kitty) – from [Terminal for Plasma](changes/done/2026-10-11-terminal-for-plasma/)
5. check: Ghostty in a real niri session (Mod+Enter, network click, light/dark); then remove the Alacritty colours (technical debt in `architecture.md`)
