#!/bin/bash
#
# IruDiag - menu bar status and actions for the Iru agent.
# Platypus "Status Menu" script: called with no args to build the menu,
# called again with the clicked item's title as $1 to perform an action.
#
# iru requires root for every subcommand. This relies on the sudoers
# drop-in installed by install-sudoers.sh (see README) granting NOPASSWD
# access to this one binary, so no auth dialog is ever needed. -n makes
# sudo fail fast with a clear error instead of hanging if that drop-in
# isn't present.

IRU="/usr/local/bin/iru"

# Ask the user to confirm before running something with side effects.
confirm() {
    local message="$1"
    local result
    result=$(/usr/bin/osascript -e "display dialog \"$message\" buttons {\"Cancel\", \"Continue\"} default button \"Continue\" with icon caution with title \"IruDiag\"" 2>&1)
    [[ "$result" == *"Continue"* ]]
}

# Strip ANSI escape codes (iru colorizes its output).
strip_ansi() {
    printf '%s' "$1" | sed -E $'s/\x1b\\[[0-9;]*[a-zA-Z]//g'
}

# Collapse command output to a single, trimmed line for use as a menu title.
sanitize() {
    strip_ansi "$1" | tr '\n' ' ' | tr '|' '/' | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//'
}

# Show text output in a real, scrollable window.
show_output() {
    local title="$1"
    local body="$2"
    local tmpfile
    tmpfile="$(mktemp -t iruDiag).txt"
    {
        printf '%s\n' "$title"
        printf '%s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
        printf -- '----------------------------------------\n\n'
        printf '%s\n' "$body"
    } > "$tmpfile"
    open -a TextEdit "$tmpfile"
}

# Run a command and show its output in a window.
run_and_show() {
    local title="$1"
    shift
    local output
    output="$("$@" 2>&1)"
    show_output "$title" "$(strip_ansi "$output")"
}

# Confirm, then run a command and show its output.
confirm_and_run() {
    local message="$1"
    local title="$2"
    shift 2
    if confirm "$message"; then
        run_and_show "$title" "$@"
    fi
}

if [ $# -eq 0 ]; then
    # Build the menu: three read-only status lines, then the actions.
    VERSION_OUT="$(sudo -n "$IRU" version 2>&1)"
    LIBRARY_OUT="$(sudo -n "$IRU" library --state 2>&1)"
    LASTRUN_OUT="$(sudo -n "$IRU" last-run 2>&1)"

    echo "DISABLED|Version: $(sanitize "$VERSION_OUT")"
    echo "DISABLED|Library: $(sanitize "$LIBRARY_OUT")"
    echo "DISABLED|Last check-in: $(sanitize "$LASTRUN_OUT")"
    echo "----"
    echo "Quick check in"
    echo "Daily check in"
    echo "Inventory update"
    echo "Installed library list"
    echo "Cancel current install"
    echo "Initiate library installs"
    echo "Show logs (5 min)"
    echo "----"
    echo "Quit"
else
    case "$1" in
        "Quick check in")
            confirm_and_run "Run a quick check-in now?

iru run -F" "Quick Check In" sudo -n "$IRU" run -F
            ;;
        "Daily check in")
            confirm_and_run "Reset and run the daily check-in now?

iru run --reset-daily" "Daily Check In" sudo -n "$IRU" run --reset-daily
            ;;
        "Inventory update")
            confirm_and_run "Send an inventory update to MDM now?

iru update-mdm" "Inventory Update" sudo -n "$IRU" update-mdm
            ;;
        "Installed library list")
            run_and_show "Installed Library List" sudo -n "$IRU" library --list
            ;;
        "Cancel current install")
            confirm_and_run "Cancel the current library install?

iru library --cancel" "Cancel Current Install" sudo -n "$IRU" library --cancel
            ;;
        "Initiate library installs")
            confirm_and_run "Initiate library installs now?

iru library" "Initiate Library Installs" sudo -n "$IRU" library
            ;;
        "Show logs (5 min)")
            run_and_show "Iru Logs (last 5 min)" sudo -n "$IRU" logs --last 300
            ;;
        "Quit")
            echo "QUITAPP"
            ;;
    esac
fi
