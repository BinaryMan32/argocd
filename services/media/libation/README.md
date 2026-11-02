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

## Migrating desktop settings

With the deployment scaled to 1 and the desktop Libation closed, run:

```sh
KUBECTL_ARGS="--context griffin" ./migrate-settings.sh
```

It copies `~/.local/share/Libation` except logs into `/config/libation-import`
and deletes the pod. On startup the init script moves any existing
`/config/Libation` aside to a timestamped backup, then moves the import into
its place.

Stop using the desktop install afterwards, or the two databases diverge.
