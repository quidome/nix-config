default:
  @just --list

switch:
  sudo nixos-rebuild --flake . switch

boot:
  sudo nixos-rebuild --flake . boot

gc:
  nix-collect-garbage -d
  sudo nix-collect-garbage -d

fmt:
  alejandra .

lint:
  statix check . && deadnix .

check:
  nix flake check

verify:
  just fmt
  just lint
  just check

update: _update-lock-and-push

refresh:
  just update
  just gc

update-switch: _update-lock-and-push _gc-and-switch

pull-update:
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
