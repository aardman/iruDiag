#!/bin/bash
#
# Installs a sudoers drop-in granting passwordless sudo for the Iru CLI,
# so IruDiag.app never has to show a password prompt. Deploy this via
# Kandji (e.g. as a postinstall/custom script) alongside IruDiag.app,
# run as root.

set -euo pipefail

SUDOERS_FILE="/etc/sudoers.d/iru-diag"
IRU="/usr/local/bin/iru"

TMPFILE="$(mktemp)"
trap 'rm -f "$TMPFILE"' EXIT

cat > "$TMPFILE" << EOF
# Allow any user to run the Iru CLI without a password - used by IruDiag.app
ALL ALL=(root) NOPASSWD: $IRU
EOF

if ! /usr/sbin/visudo -cf "$TMPFILE"; then
    echo "Generated sudoers file failed validation, not installed" >&2
    exit 1
fi

install -m 0440 -o root -g wheel "$TMPFILE" "$SUDOERS_FILE"
echo "Installed $SUDOERS_FILE"
