# Variables
hosts := `ls hosts 2>/dev/null || echo ""`

# Show available recipes
default:
    @just --list

# === System Management ===

# Build and switch current system
switch:
    sudo nixos-rebuild --flake . switch

# Show what would change without building
diff:
    nixos-rebuild --flake . build --dry-run 2>&1 | grep -E "^\s*(will be|would be)"

# Build for next boot (doesn't activate immediately)
boot:
    sudo nixos-rebuild --flake . boot

# Rollback to previous generation
rollback:
    sudo nixos-rebuild --flake . --rollback switch

# List system generations
generations:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# === Host Configuration Testing ===

# Build all host configurations (for testing)
test-hosts:
    #!/usr/bin/env bash
    set -euo pipefail
    for host in $(ls hosts); do
        echo "Building NixOS configuration for host: $host"
        nixos-rebuild --flake .#$host build
        echo "✅ $host build completed successfully"
        echo "---"
    done

# Check all host configurations without building
check-hosts:
    #!/usr/bin/env bash
    set -euo pipefail
    for host in $(ls hosts); do
        echo "Checking configuration for host: $host"
        nix build .#nixosConfigurations.$host.config.system.build.toplevel --dry-run
        echo "✅ $host check passed"
        echo "---"
    done

# Build configuration for specific host
build-host HOST:
    nixos-rebuild --flake .#{{HOST}} build

# === Updates and Maintenance ===

# Complete system refresh (update, clean, rebuild)
refresh: update clean switch

# Pull latest changes, clean, and rebuild all hosts
sync: _git-pull clean test-hosts

# Update flake.lock and nix-index cache
update: update-flake update-index

# Update flake.lock
update-flake:
    #!/usr/bin/env bash
    set -euo pipefail
    nix flake update
    if git diff --quiet --exit-code flake.lock; then
        echo "No changes to flake.lock"
    else
        git add flake.lock
        if git commit -m 'update flake.lock'; then
            git push || echo "⚠️  Failed to push flake.lock update"
        fi
    fi

# Update nix-index cache (for comma command)
update-index:
    #!/usr/bin/env bash
    location=~/.cache/nix-index
    filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr '[:upper:]' '[:lower:]')"
    mkdir -p "$location"
    wget -P "$location" -q -N "https://github.com/nix-community/nix-index-database/releases/latest/download/$filename"
    ln -f "$location/$filename" "$location/files"

# Garbage collect old generations
clean:
    nix-collect-garbage -d
    sudo nix-collect-garbage -d

# === Validation ===

# Quick syntax check of flake
validate:
    nix flake check

# Format Nix files with alejandra
format:
    find . -name '*.nix' -not -path '*/.*' -exec alejandra {} +

# Check git-crypt encryption status
check-secrets:
    #!/usr/bin/env bash
    echo "Checking git-crypt status..."
    if git-crypt status | grep -q "not encrypted"; then
        echo "⚠️  WARNING: Some files may not be properly encrypted!"
        git-crypt status
        exit 1
    else
        echo "✅ All encrypted files are secure"
    fi

# === Live Images ===

# Build base ISO image
iso-base:
    nix build .#nixosConfigurations.baseIso.config.system.build.isoImage
    @echo "ISO created at: result/iso/"

# Build bcachefs ISO image
iso-bcachefs:
    nix build .#nixosConfigurations.bcachefsIso.config.system.build.isoImage
    @echo "ISO created at: result/iso/"

# === Internal Recipes ===

# Pull latest changes from git
_git-pull:
    git pull
