# justfile

# Default recipe (runs when just is called without arguments)
default:
    @just --list

# Do a complete cleanup and update run
all: update-flake collect-garbage build update-nixpkgs-cache-index

# Build system and home
build: build-system build-home

# Build system
build-system:
    sudo nixos-rebuild --flake . switch

# Build home
build-home:
    home-manager --flake . switch

# Collect garbage   
collect-garbage:
    nix-collect-garbage -d
    sudo nix-collect-garbage -d

# Download Nixpkgs cache index
update-nixpkgs-cache-index:
    #!/usr/bin/env bash
    location=~/.cache/nix-index
    filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr '[:upper:]' '[:lower:]')"
    mkdir -p "$location"
    wget -P "$location" -q -N "https://github.com/nix-community/nix-index-database/releases/latest/download/$filename"
    ln -f "$location/$filename" "$location/files"

# Update flake and commit changes
update-flake:
    nix flake update || just _error "Failed to update flake"
    git commit -m 'update flake.lock' flake.lock
    git push || echo "Failed to push flake.lock update"

# Error handling function
_error:
    #!/usr/bin/env bash
    echo "Error: $1" >&2
    exit 1
