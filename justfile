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
  nixos-rebuild --flake .#{{HOST}} dry-activate

# Build host configuration without activating it
build HOST=current_host:
  nixos-rebuild --flake .#{{HOST}} build

# Garbage-collect user and system generations (local or remote)
gc HOST=current_host OPTS="-d":
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
update:
  nix flake update
  just _push-lock

# Update lockfile, switch, push the lockfile, then garbage-collect
upgrade HOST=current_host:
  nix flake update
  just switch {{HOST}}
  just _push-lock
  just _gc-keep {{HOST}}

# Pull latest changes, switch, then garbage-collect
sync HOST=current_host:
  #!/usr/bin/env bash
  set -euo pipefail
  git pull
  just switch {{HOST}}
  just _gc-keep {{HOST}}

_push-lock:
  #!/usr/bin/env bash
  set -euo pipefail

  if ! git diff --quiet -- flake.lock; then
    git add flake.lock
    git commit -m "chore(flake): update lockfile"
    git push
  else
    echo "No flake.lock changes; skipping commit/push."
  fi

# Keep recent generations, so a new switch can still be rolled back
_gc-keep HOST=current_host:
  just gc {{HOST}} "--delete-older-than 14d"

# Host-specific actions (machine-level)
host HOST ACTION="switch":
  #!/usr/bin/env bash
  set -euo pipefail

  local_host="{{current_host}}"
  target_host="{{HOST}}"

  case "{{ACTION}}" in
    apply|switch)
      if [ "$target_host" = "$local_host" ]; then
        sudo nixos-rebuild --flake .#{{HOST}} switch
      else
        nixos-rebuild --flake .#{{HOST}} --target-host "root@$target_host" switch
      fi
      ;;
    boot)
      if [ "$target_host" = "$local_host" ]; then
        sudo nixos-rebuild --flake .#{{HOST}} boot
      else
        nixos-rebuild --flake .#{{HOST}} --target-host "root@$target_host" boot
      fi
      ;;
    *)
      echo "Unknown host action: {{ACTION}}" >&2
      echo "Use: switch | boot" >&2
      exit 1
      ;;
  esac
