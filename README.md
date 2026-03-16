# AUR Packages

Automated AUR package maintenance using GitHub Actions + nvchecker.

## Packages

| Package | Upstream | Description |
|---------|----------|-------------|
| [jean-bin](packages/jean-bin) | [coollabsio/jean](https://github.com/coollabsio/jean) | AI assistant built with Tauri |

## How it works

1. **nvchecker** monitors upstream GitHub releases every 6 hours
2. When a new version is detected, GitHub Actions:
   - Updates the PKGBUILD with the new version
   - Recalculates checksums
   - Test-builds the package in an Arch Linux container
   - Pushes the updated PKGBUILD to AUR
   - Commits the version state back to this repo

## Adding a new package

1. Create `packages/<pkgname>/PKGBUILD`
2. Add an entry to `nvchecker.toml`
3. Add the current version to `old_ver.json`
4. Push — the automation handles the rest

## Setup

### AUR SSH Key

Generate a dedicated key and add it to your AUR account:

```bash
ssh-keygen -t ed25519 -f aur_key -N "" -C "aur-publish"
```

Add the **public key** to https://aur.archlinux.org/account/ and the **private key** as GitHub secret `AUR_SSH_PRIVATE_KEY`.

### GitHub Repository Settings

**Secrets:**
- `AUR_SSH_PRIVATE_KEY` — Private SSH key for AUR

**Variables:**
- `AUR_USERNAME` — Your AUR username
- `AUR_EMAIL` — Your AUR email

## Manual operations

```bash
# Update a package locally
./scripts/update-package.sh jean-bin 0.2.0

# Publish to AUR locally
./scripts/publish-to-aur.sh jean-bin

# Trigger update check manually
gh workflow run update-aur.yml
```
