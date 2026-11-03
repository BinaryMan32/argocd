# Libation

[Libation](https://getlibation.com) downloads and decrypts Audible books into
the audiobookshelf library.

Libation is a desktop app with no web UI, so it runs in the linuxserver
[selkies base image](https://docs.linuxserver.io/images/docker-baseimage-selkies/),
which streams a desktop to the browser. No maintained arm64 image exists, so
[config/install-libation.sh](./config/install-libation.sh) installs the pinned
release at startup from `/custom-cont-init.d` and sets libation as the desktop
autostart. `RESTART_APP` relaunches it if the window is closed.

The deployment has no `replicas`, so argocd doesn't reset manual scaling.
Scale it to 1 to use the UI, and back to 0 when done.

The config volume is `ReadWriteOncePod`, so only one pod at a time can use the
libation database.

Books are mounted at `/mnt/nfs/media/media/audiobooks`, the same path as the
desktop install, so `Books` in `Settings.json` and file paths saved in
`FileLocationsV2.json` work unchanged.

## Scheduled downloads

The `libation` CronJob runs the official
[docker image](https://getlibation.com/docs/installation/docker) daily, which
scans all accounts and downloads every book that isn't liberated yet. Mark books
that shouldn't be downloaded in the UI first. The image and
`LIBATION_VERSION` in the init script must match, renovate updates them together.

The job uses the same config volume, so a run waits while the UI is scaled up,
and the UI waits for a running job. A run that hasn't finished after 6 hours fails.

Downloads from CDNs sometimes stall without the connection closing (#1670), and
libation never times out, so the job runs
[config/liberate-watchdog.sh](./config/liberate-watchdog.sh) instead of the
image's loop. It restarts `liberate` when the process reads and
writes less than 1 MiB of files in 5 minutes, up to 5 times. A stalled
process still does a few bytes of runtime housekeeping io now and then.
Libation prints no progress without a terminal, so the script also logs each
download's progress once a minute.

The image works on copies of `Settings.json` and `AccountsSettings.json`, so
changes it makes to them aren't saved, and it doesn't update
`FileLocationsV2.json`. Run a job by hand from the CronJob's Create Job action in
argocd.

### Audiobookshelf scan

Audiobookshelf can't watch for files written over NFS by another client, so
after libation finishes, a second container asks it to scan the Audible library.
Libation runs as an init container, so the scan only runs if it succeeds.

Library scans require an Audiobookshelf admin, and API keys can't be limited to
scanning, so create a dedicated admin user (e.g. `libation-scan`) and an API key
for it, then seal the key:

```sh
./create-sealed-secret-audiobookshelf.sh
```

## Encryption key

Libation encrypts the account tokens in `AccountsSettings.json` with a master
key, which the desktop keeps in the OS keyring. The container has no keyring,
so without a key Libation can't decrypt imported tokens, creates its own
`libation-master.key` next to them and starts with no accounts.

[create-sealed-secret-master-key.sh](./create-sealed-secret-master-key.sh)
exports the desktop key into the `libation-master-key` sealed secret, mounted
outside `/config` and found via `LIBATION_MASTER_KEY_FILE`, so the config
volume and its backups only hold encrypted tokens:

```sh
./create-sealed-secret-master-key.sh
```

## Migrating desktop settings

Create the encryption key secret first. With the deployment scaled to 1 and the desktop Libation closed, run:

```sh
./migrate-settings.sh
```

It copies `~/.local/share/Libation` except logs into `/config/libation-import`
and deletes the pod. On startup the init script moves any existing
`/config/Libation` aside to a timestamped backup, then moves the import into
its place.

Stop using the desktop install afterwards, or the two databases diverge.
