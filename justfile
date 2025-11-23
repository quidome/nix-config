# Default recipe
default:
    @just --list | grep -v '# Default recipe'

# Do a complete cleanup and update run
all: update gc build

# Git pull, GC and build
pull-gc-build: _git-pull gc build

# Build system
build:
    sudo nixos-rebuild --flake . switch

# Build home
build-home:
    home-manager --flake . switch

# Nix garbage collection   
gc:
    nix-collect-garbage -d
    sudo nix-collect-garbage -d

_git-pull:
    git pull

# Update flake.lock and package cache
update: update-flake update-pkgs-cache

# Update nixpkgs cache index (for comma)
update-pkgs-cache:
    #!/usr/bin/env bash
    location=~/.cache/nix-index
    filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr '[:upper:]' '[:lower:]')"
    mkdir -p "$location"
    wget -P "$location" -q -N "https://github.com/nix-community/nix-index-database/releases/latest/download/$filename"
    ln -f "$location/$filename" "$location/files"

# Update flake and commit changes
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

# Error handling function
_error:
    #!/usr/bin/env bash
    echo "Error: $1" >&2
    exit 1
