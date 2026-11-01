# Nix repo task runner

current_host := `hostname -s 2>/dev/null || hostname`

# Show available recipes
default:
  @just --list

# Apply configuration to target host immediately
switch HOST=current_host:
  @just host {{HOST}} switch

# Apply configuration to target host on next boot
boot HOST=current_host:
  @just host {{HOST}} boot

# Dry-run activation to show what would change
plan HOST=current_host:
  @just host {{HOST}} dry-activate

# Build host configuration without activating it
build HOST=current_host:
  nixos-rebuild --flake .#{{HOST}} build

# Garbage-collect generations older than 14 days (local or remote); OPTS="-d" removes all
gc HOST=current_host OPTS="--delete-older-than 14d":
  #!/usr/bin/env bash
  set -euo pipefail

  local_host="{{current_host}}"
  target_host="{{HOST}}"

  if [ "$target_host" = "$local_host" ]; then
    nix-collect-garbage {{OPTS}}
    sudo nix-collect-garbage {{OPTS}}
    exit 0
  fi

  hm_users="$(nix eval --json .#nixosConfigurations.{{HOST}}.config.home-manager.users --apply builtins.attrNames | jq -r '.[]')"

  if [ -n "$hm_users" ]; then
    while IFS= read -r u; do
      [ -n "$u" ] || continue
      ssh "root@$target_host" "sudo -Hiu '$u' nix-collect-garbage {{OPTS}}"
    done <<< "$hm_users"
  fi

  ssh "root@$target_host" "nix-collect-garbage {{OPTS}}"

# Format Nix files
fmt:
  alejandra .

# Run static lint checks
lint:
  statix check . && deadnix --fail .

# Run flake checks
check:
  nix flake check

# Run fmt, lint, and check
verify:
  just fmt
  just lint
  just check

# Update flake.lock and auto-commit/push if changed
update:
  nix flake update
  just _push-lock

# Update lockfile, switch, push the lockfile, then garbage-collect
upgrade HOST=current_host:
  nix flake update
  just switch {{HOST}}
  just _push-lock
  just gc {{HOST}}

# Pull latest changes, switch, then garbage-collect
sync HOST=current_host:
  #!/usr/bin/env bash
  set -euo pipefail
  git pull
  just switch {{HOST}}
  just gc {{HOST}}

_push-lock:
  #!/usr/bin/env bash
  set -euo pipefail

  if ! git diff --quiet -- flake.lock; then
    git add flake.lock
    git commit -m "chore(flake): update lockfile" -- flake.lock
    git push
  else
    echo "No flake.lock changes; skipping commit/push."
  fi

# Host-specific actions (machine-level)
host HOST ACTION="switch":
  #!/usr/bin/env bash
  set -euo pipefail

  local_host="{{current_host}}"
  target_host="{{HOST}}"

  case "{{ACTION}}" in
    apply|switch) action=switch ;;
    boot) action=boot ;;
    dry-activate) action=dry-activate ;;
    *)
      echo "Unknown host action: {{ACTION}}" >&2
      echo "Use: switch | boot | dry-activate" >&2
      exit 1
      ;;
  esac

  if [ "$target_host" = "$local_host" ]; then
    sudo nixos-rebuild --flake .#{{HOST}} "$action"
  else
    nixos-rebuild --flake .#{{HOST}} --target-host "root@$target_host" "$action"
  fi
