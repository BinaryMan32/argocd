# QBittorrent

See [dockerhub](https://hub.docker.com/r/linuxserver/qbittorrent)

## Set Password

After deploying, you should see something like this in the qbittorrent pod logs:

```text
The WebUI administrator username is: admin
The WebUI administrator password was not set. A temporary password is provided for this session: PASSWORD
You should set your own password in program preferences.
```

To set the password:

1. Log in with the temporary password at <https://qbittorrent.int.fivebytestudios.com/>
2. Go to **Tools** > **Options...**
3. Click the **WebUI** tab
4. Set password using password manager

## Update Settings

Documents other manual configuration in **Tools** > **Options...**

- **Downloads**
    - **Saving Management**
        - Default Torrent Management Mode: `Manual`
        - Default Save Path: `/data/torrents/complete`
        - Keep incomplete torrents in: `On` - `/data/torrents/incomplete`
- **BitTorrent**
    - **Seeding Limits**
        - When ratio reaches `1.25`
        - When total seeding time reaches `2880` minutes
        - When inactive seeding time reaches `1440` minutes
- **WebUI**
    - **Authentication**
        - check **Bypass authentication for clients on localhost** (allows gluetun sidecar to set port forward)
