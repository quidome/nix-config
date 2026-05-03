# Multi-host Nix repo task runner

hosts := `ls hosts 2>/dev/null || echo ""`
current_host := `h=$(hostname -s 2>/dev/null || hostname); if [ -d "hosts/$h" ]; then echo "$h"; else h2=$(hostname); if [ -d "hosts/$h2" ]; then echo "$h2"; else echo "$h"; fi; fi`

default:
  @just --list

# Short aliases
check:
  @just repo check

fmt:
  @just repo fmt

update:
  @just repo update

clean:
  @just repo clean

refresh:
  @just repo refresh

plan HOST=current_host:
  @just host {{HOST}} plan

build HOST=current_host:
  @just host {{HOST}} build

switch HOST=current_host:
  @just host {{HOST}} switch

boot HOST=current_host:
  @just host {{HOST}} boot

rollback HOST=current_host:
  @just host {{HOST}} rollback

generations HOST=current_host:
  @just host {{HOST}} generations

# Repo-wide actions (codebase-level)
repo ACTION="check":
  #!/usr/bin/env bash
  set -euo pipefail
  case "{{ACTION}}" in
    check)
      nix flake check
      ;;
    fmt|format)
      find . -name '*.nix' -not -path '*/.*' -exec alejandra {} +
      ;;
    update)
      nix flake update
      ;;
    clean)
      nix-collect-garbage -d
      sudo nix-collect-garbage -d
      ;;
    refresh)
      nix flake update
      nix-collect-garbage -d
      sudo nix-collect-garbage -d
      ;;
    *)
      echo "Unknown repo action: {{ACTION}}" >&2
      echo "Use: check | fmt | update | clean | refresh" >&2
      exit 1
      ;;
  esac

# Host-specific actions (machine-level)
host HOST ACTION="plan":
  #!/usr/bin/env bash
  set -euo pipefail

  local_host="$(hostname -s 2>/dev/null || hostname)"
  if [ ! -d "hosts/$local_host" ]; then
    full_local_host="$(hostname)"
    if [ -d "hosts/$full_local_host" ]; then
      local_host="$full_local_host"
    fi
  fi
  target_host="{{HOST}}"

  case "{{ACTION}}" in
    plan)
      nix build .#nixosConfigurations.{{HOST}}.config.system.build.toplevel --dry-run
      ;;
    build)
      nixos-rebuild --flake .#{{HOST}} build
      ;;
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
    undo|rollback)
      if [ "$target_host" = "$local_host" ]; then
        sudo nixos-rebuild --flake .#{{HOST}} --rollback switch
      else
        nixos-rebuild --flake .#{{HOST}} --target-host "root@$target_host" --rollback switch
      fi
      ;;
    generations)
      if [ "$target_host" = "$local_host" ]; then
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
      else
        ssh "root@$target_host" 'nix-env --list-generations --profile /nix/var/nix/profiles/system'
      fi
      ;;
    *)
      echo "Unknown host action: {{ACTION}}" >&2
      echo "Use: plan | build | switch | boot | rollback | generations" >&2
      exit 1
      ;;
  esac

# Optional: all-host checks
hosts ACTION="plan":
  #!/usr/bin/env bash
  set -euo pipefail
  for host in $(ls hosts); do
    echo "==> $host"
    case "{{ACTION}}" in
      plan)
        nix build .#nixosConfigurations.$host.config.system.build.toplevel --dry-run
        ;;
      build)
        nixos-rebuild --flake .#$host build
        ;;
      *)
        echo "Unknown hosts action: {{ACTION}}" >&2
        echo "Use: plan | build" >&2
        exit 1
        ;;
    esac
  done

# ISO builds
iso TYPE="base":
  #!/usr/bin/env bash
  set -euo pipefail
  case "{{TYPE}}" in
    base)
      nix build .#nixosConfigurations.baseIso.config.system.build.isoImage
      echo "ISO created at: result/iso/"
      ;;
    bcachefs)
      nix build .#nixosConfigurations.bcachefsIso.config.system.build.isoImage
      echo "ISO created at: result/iso/"
      ;;
    *)
      echo "Unknown iso type: {{TYPE}}" >&2
      echo "Use: base | bcachefs" >&2
      exit 1
      ;;
  esac
