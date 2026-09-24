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
gc HOST=current_host:
  #!/usr/bin/env bash
  set -euo pipefail

  local_host="{{current_host}}"
  target_host="{{HOST}}"

  if [ "$target_host" = "$local_host" ]; then
    nix-collect-garbage -d
    sudo nix-collect-garbage -d
    exit 0
  fi

  hm_users="$(nix eval --json .#nixosConfigurations.{{HOST}}.config.home-manager.users --apply builtins.attrNames | jq -r '.[]')"

  if [ -n "$hm_users" ]; then
    while IFS= read -r u; do
      [ -n "$u" ] || continue
      ssh "root@$target_host" "sudo -Hiu '$u' nix-collect-garbage -d"
    done <<< "$hm_users"
  fi

  ssh "root@$target_host" "nix-collect-garbage -d"

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
upgrade HOST=current_host:
  just _update-lock-and-push
  just _gc-and-switch {{HOST}}

# Pull latest changes, then garbage-collect and switch
sync HOST=current_host:
  #!/usr/bin/env bash
  set -euo pipefail
  git pull
  just _gc-and-switch {{HOST}}

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

_gc-and-switch HOST=current_host:
  just gc {{HOST}}
  just switch {{HOST}}

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
