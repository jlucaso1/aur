#!/usr/bin/env bash
# Updates a package's PKGBUILD with a new version and recalculates checksums
set -euo pipefail

PKGNAME="$1"
NEW_VER="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
PKG_DIR="${REPO_DIR}/packages/${PKGNAME}"
PKGBUILD="${PKG_DIR}/PKGBUILD"

if [[ ! -f "$PKGBUILD" ]]; then
    echo "ERROR: PKGBUILD not found at ${PKGBUILD}"
    exit 1
fi

echo "==> Updating ${PKGNAME} to version ${NEW_VER}"

# Update pkgver
sed -i "s/^pkgver=.*/pkgver=${NEW_VER}/" "$PKGBUILD"

# Reset pkgrel to 1
sed -i "s/^pkgrel=.*/pkgrel=1/" "$PKGBUILD"

# Recalculate checksums using updpkgsums (from pacman-contrib)
cd "$PKG_DIR"
updpkgsums

echo "==> Updated ${PKGNAME} PKGBUILD to ${NEW_VER}"
