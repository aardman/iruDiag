# IruDiag

A menu bar diagnostics and maintenance tool for the [Iru](https://www.iru.com) client agent.

Shows live status straight in the menu bar:

* Version - `iru version`
* Library Status - `iru library --state`
* Last check in - `iru last-run`

And a set of actions, each showing its result in a window:

* Quick check in - `iru run -F`
* Daily check in - `iru run --reset-daily`
* Inventory update - `iru update-mdm`
* Installed library list - `iru library --list`
* Cancel current install - `iru library --cancel`
* Initiate library installs - `iru library`
* Show logs (5 min) - `iru logs --last 300`

## How it works

IruDiag is a [Platypus](https://sveinbjorn.org/platypus) "Status Menu" app wrapping
[iruDiag.sh](iruDiag.sh). `iru` requires root for every subcommand, so the installer sets
up a sudoers drop-in (`/etc/sudoers.d/iru-diag`) granting passwordless `sudo` for just
`/usr/local/bin/iru` - the app itself never shows a password prompt.

(An earlier version tried a GUI admin-privileges prompt per action instead. Both the
AppleScript `do shell script "..." with administrator privileges` route and Platypus's own
`-A`/admin-privileges flag turned out to be unreliable for a background/status-menu app on
current macOS - one produced an authentication dialog that couldn't receive keyboard input,
the other silently failed to elevate at all. The sudoers approach actually works.)

## Installing

Download `IruDiag.pkg` from the [Releases](../../releases) page (or build it yourself, see
below) and run:

```
sudo installer -pkg IruDiag.pkg -target /
```

This installs the app to `/Applications/IruDiag.app` and sets up the sudoers drop-in via a
postinstall script. Launch it from Spotlight, Finder, or your MDM of choice - it isn't set
to launch automatically at login.

## Building from source

Requires [Platypus](https://sveinbjorn.org/platypus) (`/Applications/Platypus.app`).

```
./build.sh      # (re)builds IruDiag.app from iruDiag.sh
./package.sh    # builds IruDiag.pkg from IruDiag.app
```

`package.sh` also disables `pkgbuild`'s default bundle relocation
(`BundleIsRelocatable`): without this, if Launch Services already knows an app with this
identifier exists somewhere the installer silently installs there instead of `/Applications` - no error,
no warning. Worth checking `pkgutil --payload-files IruDiag.pkg` after any change to
confirm it still lands where you expect.

## Files

* `iruDiag.sh` - the wrapped script
* `build.sh` - rebuilds `IruDiag.app` from `iruDiag.sh`
* `postinstall` - the package postinstall that installs the sudoers drop-in
* `install-sudoers.sh` - the same sudoers setup, standalone, for manual/local testing
  (`sudo bash install-sudoers.sh`)
* `package.sh` - builds `IruDiag.pkg` from `IruDiag.app`

## Deploying via MDM

If you manage a fleet of Macs using Iru, upload `IruDiag.pkg` as a custom
package/app library item and assign it to the relevant scope/blueprint. It runs via
`installer` as root, same as a manual install, and needs no further configuration.

## License

MIT - see [LICENSE](LICENSE).
