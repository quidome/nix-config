#!/usr/bin/env bash
# Security check script to prevent accidental sharing of encrypted files

set -euo pipefail

# Files that should never be shared (from .gitattributes)
PROTECTED_FILES=(
    "hardware-configuration.nix"
    "home-vars.nix" 
    "secrets.nix"
    "system-vars.nix"
    "vars.nix"
)

echo "🔒 Security Check: Ensuring no encrypted files are exposed..."

# Check if any protected files are staged for commit
if git diff --cached --name-only | grep -E "$(IFS='|'; echo "${PROTECTED_FILES[*]}")"; then
    echo "❌ ERROR: Attempting to commit encrypted files!"
    echo "These files should never be committed unencrypted:"
    git diff --cached --name-only | grep -E "$(IFS='|'; echo "${PROTECTED_FILES[*]}")"
    exit 1
fi

# Check git-crypt status
if command -v git-crypt >/dev/null 2>&1; then
    echo "🔐 Checking git-crypt status..."
    git-crypt status
else
    echo "⚠️  git-crypt not installed - cannot verify encryption status"
fi

# Check for any accidental exposure in recent commits
echo "🔍 Scanning recent commits for potential leaks..."
for file in "${PROTECTED_FILES[@]}"; do
    if git log --oneline --name-only -10 | grep -q "$file"; then
        echo "⚠️  WARNING: $file found in recent commit history"
        echo "Verify this was committed encrypted with git-crypt"
    fi
done

echo "✅ Security check complete"