#!/usr/bin/env bash
# Publishes a package to AUR
set -euo pipefail

PKGNAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
PKG_DIR="${REPO_DIR}/packages/${PKGNAME}"
PKGBUILD="${PKG_DIR}/PKGBUILD"
AUR_DIR="/tmp/aur-${PKGNAME}"

if [[ ! -f "$PKGBUILD" ]]; then
    echo "ERROR: PKGBUILD not found at ${PKGBUILD}"
    exit 1
fi

# Extract version from PKGBUILD
PKGVER=$(grep '^pkgver=' "$PKGBUILD" | cut -d= -f2)

echo "==> Publishing ${PKGNAME} v${PKGVER} to AUR"

# Clone or update AUR repo
if [[ -d "$AUR_DIR" ]]; then
    rm -rf "$AUR_DIR"
fi
git clone "ssh://aur@aur.archlinux.org/${PKGNAME}.git" "$AUR_DIR" 2>/dev/null || {
    echo "==> Package doesn't exist on AUR yet, creating new repo"
    mkdir -p "$AUR_DIR"
    cd "$AUR_DIR"
    git init
    git remote add origin "ssh://aur@aur.archlinux.org/${PKGNAME}.git"
}

# Copy PKGBUILD and generate .SRCINFO
cp "$PKGBUILD" "$AUR_DIR/"

# Copy any extra files (*.install, patches, etc.)
for f in "$PKG_DIR"/*.install "$PKG_DIR"/*.patch; do
    [[ -f "$f" ]] && cp "$f" "$AUR_DIR/"
done

cd "$AUR_DIR"

# Generate .SRCINFO
makepkg --printsrcinfo > .SRCINFO

# Commit and push
git add -A
if git diff --cached --quiet; then
    echo "==> No changes to publish for ${PKGNAME}"
else
    git commit -m "Update ${PKGNAME} to ${PKGVER}"
    git push origin master
    echo "==> Published ${PKGNAME} v${PKGVER} to AUR"
fi

# Cleanup
rm -rf "$AUR_DIR"
