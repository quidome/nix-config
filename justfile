# Default recipe
default:
    @just --list | grep -v '# Default recipe'

# Do a complete cleanup and update run
all: update gc build

# Git pull, GC and build
pull-gc-build: _git-pull gc build-all

# Build system
build:
    sudo nixos-rebuild --flake . switch

# Build all host configurations
build-all:
    #!/usr/bin/env bash
    set -euo pipefail
    hosts="bea coolding nimbus truce"
    for host in $hosts; do
        echo "Building NixOS configuration for host: $host"
        nixos-rebuild --flake .#$host build
        echo "✅ $host build completed successfully"
        echo "---"
    done

# Check all host configurations (dry run)
check-all:
    #!/usr/bin/env bash
    set -euo pipefail
    hosts="bea coolding nimbus truce"
    for host in $hosts; do
        echo "Checking configuration for host: $host"
        nix build .#nixosConfigurations.$host.config.system.build.toplevel --dry-run
        echo "✅ $host check passed"
        echo "---"
    done

# Nix garbage collection
gc:
    nix-collect-garbage -d
    sudo nix-collect-garbage -d

# Git operations
_git-pull:
    git pull

# Update operations
update: update-flake update-pkgs-cache

# Update flake.lock and package cache
update-flake:
    #!/usr/bin/env bash
    set -euo pipefail

    nix flake update || just _error "Failed to update flake"

    if git diff --quiet --exit-code flake.lock; then
        echo "No changes to flake.lock"
    else
        git add flake.lock
        git commit -m 'update flake.lock' && git push || echo "Failed to push flake.lock update"
    fi

# Update nixpkgs cache index (for comma)
update-pkgs-cache:
    #!/usr/bin/env bash
    location=~/.cache/nix-index
    filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr '[:upper:]' '[:lower:]')"
    mkdir -p "$location"
    wget -P "$location" -q -N "https://github.com/nix-community/nix-index-database/releases/latest/download/$filename"
    ln -f "$location/$filename" "$location/files"

# Security operations
check-secrets:
    #!/usr/bin/env bash
    echo "Checking git-crypt status..."
    if ! git-crypt status | grep -q "encrypted: 0"; then
        echo "WARNING: Some files may not be properly encrypted!"
        git-crypt status
    else
        echo "All encrypted files are secure"
    fi

# Error handling function
_error:
    #!/usr/bin/env bash
    echo "Error: $1" >&2
    exit 1
