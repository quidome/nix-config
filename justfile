# Show available recipes
default:
  @just --list

# Apply configuration to current system immediately
switch:
  sudo nixos-rebuild --flake . switch

# Apply configuration on next boot
boot:
  sudo nixos-rebuild --flake . boot

# Garbage-collect user and system generations
gc:
  nix-collect-garbage -d
  sudo nix-collect-garbage -d

# Format Nix files
fmt:
  alejandra .

# Run static lint checks
lint:
  statix check . && deadnix .

# Run flake checks
check:
  nix flake check

# Run fmt, lint, and check
verify:
  just fmt
  just lint
  just check

# Update flake.lock and auto-commit/push if changed
update: _update-lock-and-push

# Update lockfile, then garbage-collect and switch
upgrade: _update-lock-and-push _gc-and-switch

# Pull latest changes, then garbage-collect and switch
sync:
  #!/usr/bin/env bash
  set -euo pipefail
  git pull
  just _gc-and-switch

_update-lock-and-push:
  #!/usr/bin/env bash
  set -euo pipefail
  nix flake update

  if ! git diff --quiet -- flake.lock; then
    git add flake.lock
    git commit -m "chore(flake): update lockfile"
    git push
  else
    echo "No flake.lock changes; skipping commit/push."
  fi

_gc-and-switch:
  just gc
  sudo nixos-rebuild --flake . switch
