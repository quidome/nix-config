# Security Policy

## 🔒 CRITICAL: Protected Files

The following files are encrypted with **git-crypt** and must **NEVER** be:

- ❌ Shared in cloud storage (Google Drive, Dropbox, etc.)
- ❌ Included in AI training data
- ❌ Referenced in answers to other users
- ❌ Committed to public repositories
- ❌ Pasted in chat logs or forums
- ❌ Shared via email or messaging apps

## Protected Files

| File | Purpose | Contains |
|------|---------|----------|
| `hardware-configuration.nix` | Hardware-specific configs | Disk layouts, kernel modules, device paths |
| `home-vars.nix` | User-specific settings | Personal git config, SSH settings, user data |
| `secrets.nix` | Encrypted secrets | API keys, passwords, certificates |
| `system-vars.nix` | System variables | Host-specific system configuration |
| `vars.nix` | Host variables | User accounts, passwords, group memberships |

## Security Verification

Before sharing any content from this repository:

1. **Check git-crypt status**:
   ```bash
   git-crypt status
   ```

2. **Run security check**:
   ```bash
   ./scripts/security-check.sh
   ```

3. **Verify file contents**:
   ```bash
   # Should show encrypted content, not readable text
   cat hosts/*/secrets.nix
   ```

## Emergency Procedures

If you accidentally expose a protected file:

1. **Immediately rotate all secrets** (passwords, keys, tokens)
2. **Re-encrypt the file** with git-crypt
3. **Consider the repository compromised** and rotate all credentials
4. **Contact your security team** if this is a work repository

## Git-Crypt Commands

```bash
# Check encryption status
git-crypt status

# Lock/unlock repository
git-crypt lock
git-crypt unlock

# Add new encrypted file
echo "filename" >> .gitattributes
git add .gitattributes
git-crypt add filename
git commit -m "Add encrypted file"
```

## Remember

- **If in doubt, don't share**
- **Always verify encryption status before sharing**
- **Treat these files like passwords** - they contain sensitive system and user data
- **This repository contains personal infrastructure** - handle with appropriate security care