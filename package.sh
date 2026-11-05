#!/bin/bash
#
# Builds IruDiag.pkg:
#   - installs IruDiag.app to /Applications/IruDiag.app
#   - postinstall sets up passwordless sudo for the Iru CLI (see postinstall)
#
# Run ./build.sh first to (re)build IruDiag.app.

set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="IruDiag.app"
INSTALL_DIR="/Applications"
IDENTIFIER="org.aardman.IruDiag.pkg"
VERSION="1.1.0"
OUTPUT="IruDiag.pkg"

if [ ! -d "$APP_NAME" ]; then
    echo "$APP_NAME not found - run ./build.sh first" >&2
    exit 1
fi

rm -rf .pkgroot .pkgscripts .component.plist
mkdir -p ".pkgroot$INSTALL_DIR"
cp -R "$APP_NAME" ".pkgroot$INSTALL_DIR/$APP_NAME"

mkdir -p .pkgscripts
cp postinstall .pkgscripts/postinstall
chmod +x .pkgscripts/postinstall

# By default pkgbuild treats a top-level .app as a relocatable bundle: if
# Launch Services already knows a bundle with this identifier exists
# elsewhere (e.g. this very app, run once from this repo checkout), the
# installer silently installs THERE instead of --install-location. Disable
# that so it always goes to the path we ask for.
pkgbuild --analyze --root .pkgroot .component.plist
# Depending on the macOS/pkgbuild version, the generated plist may or may
# not already have this key - Delete-then-Add handles both cases (Set
# fails outright if the key isn't already there).
/usr/libexec/PlistBuddy -c "Delete :0:BundleIsRelocatable" .component.plist 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :0:BundleIsRelocatable bool false" .component.plist

pkgbuild \
    --root .pkgroot \
    --component-plist .component.plist \
    --scripts .pkgscripts \
    --identifier "$IDENTIFIER" \
    --version "$VERSION" \
    --install-location / \
    "$OUTPUT"

rm -rf .pkgroot .pkgscripts .component.plist
echo "Built $OUTPUT"
